extends Node

const LIVES_PER_PLAYER = 50

var life_drain_timer: Timer

var player_roles: Dictionary = {}
var team_lives: int = 0
var team_keys: int = 0
# ...add more game state here over time

signal state_updated
signal keys_changed
signal lives_changed

func _ready() -> void:
	life_drain_timer = Timer.new()
	life_drain_timer.wait_time = 5.0
	life_drain_timer.timeout.connect(_on_life_drain_timeout)
	add_child(life_drain_timer)

func clear() -> void:
	player_roles.clear()
	team_lives = 0
	team_keys = 0
	stop_life_drain()
	state_updated.emit()
	keys_changed.emit(team_keys)
	lives_changed.emit(team_lives)

func assign_roles(peer_ids: Array) -> void:
	if not multiplayer.is_server():
		return

	var shuffled = peer_ids.duplicate()
	shuffled.shuffle()
	player_roles.clear()

	for i in shuffled.size():
		player_roles[shuffled[i]] = "monster" if i == 0 else "player"

	_push_state_to_all()

func set_starting_team_properties() -> void:
	team_keys = 0
	team_lives = get_player_count() * LIVES_PER_PLAYER
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
	team_keys = team_keys + 1
	_push_state_to_all()

func _apply_state(state: Dictionary) -> void:
	player_roles = state.get("player_roles", {})
	team_lives = state.get("team_lives", 0)
	team_keys = state.get("team_keys",  0)
	state_updated.emit()
	keys_changed.emit(team_keys)
	lives_changed.emit(team_lives)

func _build_state() -> Dictionary:
	return {
		"player_roles": player_roles,
		"team_lives":   team_lives,
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
	print("CURRENT GAME STATE FOR EVERYONE: ", state)

func _collect_key() -> void:
	if not multiplayer.is_server():
		return
	if get_player_count() > team_keys:
		team_keys += 1
		_push_state_to_all()

func _remove_lives(amount: int) -> void:
	if not multiplayer.is_server():
		return
	team_lives -= amount
	_push_state_to_all()
	if team_lives <= 0:
		print("Monster hat gewonnen")

@rpc("any_peer", "call_local", "reliable")
func request_collect_key() -> void:
	if multiplayer.is_server():
		_collect_key()

@rpc("any_peer", "call_local", "reliable")
func request_remove_life(amount: int) -> void:
	if multiplayer.is_server():
		_remove_lives(amount)

@rpc("any_peer", "call_local", "reliable")
func request_resetting_starting_properties() -> void:
	if multiplayer.is_server():
		set_starting_team_properties()

func start_life_drain() -> void:
	if not multiplayer.is_server():
		return
	life_drain_timer.start()

func stop_life_drain() -> void:
	life_drain_timer.stop()

func _on_life_drain_timeout() -> void:
	if not multiplayer.is_server():
		return
	_remove_lives(1)
