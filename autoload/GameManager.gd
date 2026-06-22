extends Node

const LIVES_PER_PLAYER = 50

var life_drain_timer: Timer

var player_roles: Dictionary = {}
var team_lives: int = 0
var max_team_lives: int = 0
var team_keys: int = 0
var fishingrod_in_inventory: bool = false
var pickaxe_in_inventory: bool = false
# todo: überlegen, ob hier vllt array einfach
var rune_inventory: Array = []
#var rune_cosmic_in_inventory: bool = false
#var rune_nature_in_inventory: bool = false
#var rune_water_in_inventory: bool = false
var game_has_ended: bool = false
# ...add more game state here over time

signal state_updated
signal keys_changed
signal lives_changed
signal players_won
signal monster_won
signal spawn_added
signal trap_sound_requested
signal trap_diffused

enum spawn_type {
	DOOR,
	PICKAXE,
	FISHINGROD,
	RUNE,
	TRAP
}

# --- Sync System ---

func _apply_state(state: Dictionary) -> void:
	player_roles = state.get("player_roles", {})
	team_lives = state.get("team_lives", 0)
	max_team_lives = state.get("max_team_lives", 0)
	team_keys = state.get("team_keys",  0)
	pickaxe_in_inventory = state.get("pickaxe_in_inventory", false)
	fishingrod_in_inventory = state.get("fishingrod_in_inventory", false)
	rune_inventory = state.get("rune_inventory", [])
	state_updated.emit()
	keys_changed.emit()
	lives_changed.emit(team_lives)

func _build_state() -> Dictionary:
	return {
		"player_roles": player_roles,
		"team_lives":   team_lives,
		"max_team_lives": max_team_lives,
		"team_keys":	team_keys,
		"pickaxe_in_inventory": pickaxe_in_inventory,
		"fishingrod_in_inventory": fishingrod_in_inventory,
		"rune_inventory": rune_inventory
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
	life_drain_timer.wait_time = 10.0
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

@rpc("any_peer", "call_local", "reliable")
func collect_rune(rune_type) -> void:
	if not multiplayer.is_server():
		return
	rune_inventory.append(rune_type)
	_push_state_to_all()

@rpc("any_peer", "call_local", "reliable")
func collect_fishingrod() -> void:
	if not multiplayer.is_server():
		return
	fishingrod_in_inventory = true
	_push_state_to_all()

@rpc("any_peer", "call_local", "reliable")
func collect_pickaxe() -> void:
	if not multiplayer.is_server():
		return
	pickaxe_in_inventory = true
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
func add_spawn(position: Vector3, type: spawn_type, rune_type = null) -> void:
	spawn_added.emit(position, type, rune_type)

@rpc("any_peer", "call_local", "reliable")
func despawn_minigame_items(groupname: String) -> void:
	get_tree().call_group(groupname, "queue_free")

# Dynamically spawned nodes (e.g. monster traps) get auto-renamed by
# add_child() and can end up at different NodePaths on different peers,
# so RPCs can't safely target them directly - route through this stable
# autoload instead and let each peer match its own local instance by position.
@rpc("any_peer", "call_local", "unreliable")
func play_trap_sound(position: Vector3) -> void:
	trap_sound_requested.emit(position)

@rpc("any_peer", "call_local", "reliable")
func notify_trap_diffused(position: Vector3) -> void:
	trap_diffused.emit(position)

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
