extends Node

const LIVES_PER_PLAYER = 50

var life_drain_timer: Timer

var player_roles: Dictionary = {}
var team_lives: int = 0
var max_team_lives: int = 0
var team_keys: int = 0
var game_has_ended: bool = false
# ...add more game state here over time

signal state_updated
signal keys_changed
signal lives_changed
signal players_won
signal monster_won
signal spawn_added

enum spawn_type {
	DOOR,
	PICKAXE,
	FISHINGROD,
	RUNE
}

# --- Sync System ---

func _apply_state(state: Dictionary) -> void:
	player_roles = state.get("player_roles", {})
	team_lives = state.get("team_lives", 0)
	max_team_lives = state.get("max_team_lives", 0)
	team_keys = state.get("team_keys",  0)
	state_updated.emit()
	keys_changed.emit()
	lives_changed.emit(team_lives)

func _build_state() -> Dictionary:
	return {
		"player_roles": player_roles,
		"team_lives":   team_lives,
		"max_team_lives": max_team_lives,
		"team_keys":	team_keys
	}

# Host calls this whenever state changes
func _push_state_to_all() -> void:
	if not multiplayer.is_server():
		return
	_receive_state.rpc(_build_state())
	
@rpc("authority", "call_local", "reliable")
func _receive_state(state: Dictionary) -> void:
	_apply_state(state)
	#print("CURRENT GAME STATE FOR EVERYONE: ", state)

# --- Game Logic ---

func _ready() -> void:
	life_drain_timer = Timer.new()
	life_drain_timer.wait_time = 5.0
	life_drain_timer.timeout.connect(_on_life_drain_timeout)
	add_child(life_drain_timer)
	
	# Enable input processing for debug functions
	process_mode = PROCESS_MODE_ALWAYS

## Reset EVERYTHING [br]
## E.g. on leave
func clear() -> void:
	player_roles.clear()
	team_lives = 0
	max_team_lives = 0
	team_keys = 0
	game_has_ended = false
	stop_life_drain()
	state_updated.emit()
	keys_changed.emit()
	lives_changed.emit(team_lives)

## Start EVERYTHING [br]
## E.g. assign the roles, set the starting team properties, start life drain etc.
func start_game(peer_ids: Array):
	_assign_roles(peer_ids)
	set_starting_team_properties()
	start_life_drain()

func _assign_roles(peer_ids: Array) -> void:
	if not multiplayer.is_server():
		return

	var shuffled = peer_ids.duplicate()
	shuffled.shuffle()
	player_roles.clear()

	for i in shuffled.size():
		player_roles[shuffled[i]] = "monster" if i == 0 else "player"

	_push_state_to_all()
	
func get_player_count() -> int:
	var player_count = 0
	for player in player_roles:
		if player_roles[player] == "player":
			player_count += 1
	return player_count

func remove_peer(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	player_roles.erase(peer_id)
	team_lives = team_lives - LIVES_PER_PLAYER
	max_team_lives = max_team_lives - LIVES_PER_PLAYER
	_push_state_to_all()

# --- Team Properties ---

@rpc("any_peer", "call_local", "reliable")
func set_starting_team_properties() -> void:
	if not multiplayer.is_server():
		return
	team_keys = 0
	team_lives = get_player_count() * LIVES_PER_PLAYER
	max_team_lives = team_lives
	_push_state_to_all()

@rpc("any_peer", "call_local", "reliable")
func collect_key() -> void:
	if not multiplayer.is_server():
		return
	if get_player_count() > team_keys:
		team_keys += 1
		_push_state_to_all()

# Get the current player's role
func get_my_role() -> String:
	var my_id = multiplayer.get_unique_id()
	return player_roles.get(my_id, "player")

@rpc("any_peer", "call_local", "reliable")
func remove_lives(amount: int) -> void:
	if not multiplayer.is_server():
		return
	team_lives -= amount
	_push_state_to_all()
	if team_lives <= 0:
		end_game.rpc(false)

@rpc("any_peer", "call_local", "reliable")
func end_game(playerVictory: bool) -> void:
	# Prevent duplicate game end triggers
	if game_has_ended:
		return
	game_has_ended = true
	
	if playerVictory:
		players_won.emit()
	else:
		monster_won.emit()
		
	if not multiplayer.is_server():
		return
	
	NetworkManager.set_lobby_not_ready.rpc()
	Steam.setLobbyJoinable(NetworkManager.lobby_id, true)
	stop_life_drain()

@rpc("any_peer", "call_local", "reliable")
func add_spawn(position: Vector3, type: spawn_type) -> void:
	spawn_added.emit(position, type)

# --- Life Drain ---

func start_life_drain() -> void:
	if not multiplayer.is_server():
		return
	life_drain_timer.start()

func stop_life_drain() -> void:
	life_drain_timer.stop()

func _on_life_drain_timeout() -> void:
	if not multiplayer.is_server():
		return
	remove_lives(1)
