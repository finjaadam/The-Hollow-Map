extends Node

var player_scene : PackedScene = preload("res://network/testEnvironment/player.tscn")
var monster_scene: PackedScene = preload("res://network/monster/monster.tscn")
var spawn_points : Node3D = null
var spawner: MultiplayerSpawner = null

var peer : SteamMultiplayerPeer
var is_host : bool = false
var is_joining : bool = false

var lobby_id : int = 0
var lobby_members: Array = []
var lobby_members_max: int = 4

var steam_id: int = 0

var player_roles: Dictionary = {}  # { peer_id: "player" | "monster" }

signal game_starting
signal lobby_is_ready
signal lobby_is_not_ready
signal lobby_updated
signal lobby_name_updated
signal player_roles_updated

var ready_states: Dictionary = {}  # { steam_id: bool }
var connected_peers: Array = []

func _assign_roles() -> void:
	var all_peers = [1] + connected_peers.duplicate()
	all_peers.shuffle()
	
	for i in all_peers.size():
		var pid = all_peers[i]
		player_roles[pid] = "monster" if i == 0 else "player"

	sync_player_roles.rpc(player_roles)

func register_world(s: MultiplayerSpawner, sp: Node3D) -> void:
	spawner = s
	spawn_points = sp
	spawner.spawn_function = _spawn_player
	
	# Shuffle all Spawnpoints
	var spawn_point_array = spawn_points.get_children().duplicate()
	spawn_point_array.shuffle()
	
	assert(spawn_point_array.size() >= connected_peers.size() + 1, "Not enough spawn points!")
	
	# Only host spawns all players
	if multiplayer.is_server():
		_add_player(spawn_point_array[0], 1)  # host, gets the first spawnpoint of shuffled array
		for i in connected_peers.size():
			_add_player(spawn_point_array[i+1], connected_peers[i])  # each remote peer gets the following spawnpoints

func _ready():
	if not SteamCheck.steam_initialized:
		print("Initializing Steam Network")
		SteamCheck.steam_initialized = Steam.steamInit(480, true)
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.persona_state_change.connect(_on_persona_change)

func _spawn_player(data: Dictionary) -> Node:
	var instance: Node
	if data.get("role", "player") == "monster":
		instance = monster_scene.instantiate()
	else:
		instance = player_scene.instantiate()

	instance.name = str(data["id"])
	instance.position = data["position"]
	instance.set_multiplayer_authority(data["id"])
	return instance

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func host_lobby():
	if lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)
		is_host = true

# You are joining YOURSELF
func join_lobby(lobby_id: int):
	is_joining = true
	lobby_members.clear()
	Steam.joinLobby(lobby_id)

func leave_lobby() -> void:
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
		lobby_id = 0
		for this_member in lobby_members:
			if this_member['steam_id'] != steam_id:
				Steam.closeP2PSessionWithUser(this_member['steam_id'])
		lobby_members.clear()
		ready_states.clear()
		player_roles.clear()

	# Clean up the multiplayer peer
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	# Disconnect multiplayer signals to avoid duplicates on next host
	if multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.disconnect(_on_peer_connected)
	if multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.disconnect(_on_peer_disconnected)

	peer = null
	is_host = false
	is_joining = false

func _on_peer_connected(id: int):
	connected_peers.append(id)
	var sid := peer.get_steam_id_for_peer_id(id)
	if sid != 0:
		ready_states[sid] = false

	# Host pushes current state snapshot to the new peer
	if multiplayer.is_server():
		sync_ready_states.rpc_id(id, ready_states)

func _on_peer_disconnected(id: int):
	connected_peers.erase(id)
	var sid := peer.get_steam_id_for_peer_id(id)
	if sid != 0:
		ready_states.erase(sid)
	_remove_player(id)
	player_roles.erase(id)

func request_lobby_list():
	# Set distance to worldwide
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("game", "HOLLOW_MAP", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func get_lobby_members() -> void:
	lobby_members.clear()
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)

	# Get the data of these players from Steam + Add to List
	for this_member in range(0, num_of_members):
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		lobby_members.append({"steam_id":member_steam_id, "steam_name":member_steam_name})
	lobby_updated.emit()

func _add_player(sp: Node, id: int = 1):
	if not multiplayer.is_server():
		return # Only host shuld call spawn

	var pos = sp.global_position
	var role = player_roles.get(id, "player")  # default to player if missing

	spawner.spawn({"id": id, "position": pos, "role": role})

func _remove_player(id: int):
	var world = get_tree().root.get_node("World")
	if not world:
		return
	for child in world.get_children():
		if child is CharacterBody3D and child.get_multiplayer_authority() == id:
			child.queue_free()
			return

# You created the Lobby yourself
func _on_lobby_created(result: int, lobby_id: int):	
	if result == Steam.RESULT_OK:
		self.lobby_id = lobby_id
		
		# Add host's own steam ID to ready_states
		var my_steam_id = Steam.getSteamID()
		ready_states[my_steam_id] = false
		steam_id = my_steam_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		# Set this lobby as joinable
		Steam.setLobbyJoinable(lobby_id, true)

		# Set some lobby data
		Steam.setLobbyData(lobby_id, "name", "Testserver")
		Steam.setLobbyData(lobby_id, "game", "HOLLOW_MAP")
		
		# Allow P2P Connections to fallback to Steam Relay
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
		get_lobby_members()
		lobby_name_updated.emit()
		print(lobby_id)

# You joined the Lobby
func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int):
	if !is_joining:
		return
	
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		get_lobby_members()
		
		self.lobby_id = lobby_id
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer
		
		is_joining = false
		lobby_name_updated.emit()
	else:
		# Get the failure reason
		var fail_reason: String

		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."

		print("Failed to join this chat room: %s" % fail_reason)
		request_lobby_list()

# A user's information has changed (downloaded info from steam that was not stored locally at first)
func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	if lobby_id > 0:
		get_lobby_members()

func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	# Get the user who has made the lobby change
	var changer_name: String = Steam.getFriendPersonaName(change_id)

	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		print("%s has joined the lobby." % changer_name)
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		print("%s has left the lobby." % changer_name)
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		print("%s has been kicked from the lobby." % changer_name)
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		print("%s has been banned from the lobby." % changer_name)
	else:
		print("%s did... something." % changer_name)
	# Update the lobby now that a change has occurred
	get_lobby_members()

func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	# Get the lobby owner's name
	var owner_name: String = Steam.getFriendPersonaName(friend_id)

	print("Joining %s's lobby..." % owner_name)

	# Attempt to join the lobby
	join_lobby(this_lobby_id)

func _on_lobby_match_list(these_lobbies: Array) -> void:
	var next_scene = preload("res://network/testEnvironment/menuServerList.tscn")
	var server_list_menu = next_scene.instantiate()
	for this_lobby in these_lobbies:
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		# Create a button for the 1 lobby each
		var lobby_button: Button = Button.new()
		lobby_button.set_text("%s: %s - %s Spielende" % [this_lobby, lobby_name, lobby_num_members])
		lobby_button.set_size(Vector2(800, 50))
		lobby_button.add_theme_font_size_override("font_size", 20)
		lobby_button.set_name("lobby_%s" % this_lobby)
		lobby_button.connect("pressed", Callable(self, "join_lobby").bind(this_lobby))
		
		server_list_menu.add_lobby(lobby_button, this_lobby)
	SceneLoader.goto_preloaded_scene(server_list_menu, "res://network/testEnvironment/menuServerList.tscn")

@rpc("any_peer", "call_local", "reliable")
func set_player_ready(is_ready: bool) -> void:
	var sender_peer_id := multiplayer.get_remote_sender_id()
	if sender_peer_id == 0:
		sender_peer_id = multiplayer.get_unique_id()

	var sid := peer.get_steam_id_for_peer_id(sender_peer_id)
	if sid == 0:
		return

	ready_states[sid] = is_ready
	lobby_updated.emit()

	if multiplayer.is_server():
		_check_all_ready()

func _check_all_ready():
	if ready_states.is_empty():
		return
	var all_ready = ready_states.values().all(func(r): return r == true)
	if all_ready:
		lobby_is_ready.emit()
		return
	lobby_is_not_ready.emit()

@rpc("authority", "call_local", "reliable")
func start_game():
	if multiplayer.is_server():
		player_roles.clear()
		_assign_roles()
		Steam.setLobbyJoinable(lobby_id, false) # No one else can join
	game_starting.emit()

func get_lobby_name() -> String:
	return Steam.getLobbyData(lobby_id, "name")

@rpc("any_peer", "call_local", "reliable")
func set_lobby_name(new_name: String):
	Steam.setLobbyData(lobby_id, "name", new_name)
	lobby_name_updated.emit()

@rpc("authority", "call_local", "reliable")
func sync_ready_states(states: Dictionary) -> void:
	ready_states = states
	lobby_updated.emit()

@rpc("authority", "call_local", "reliable")
func sync_player_roles(roles: Dictionary) -> void:
	player_roles = roles
	player_roles_updated.emit()

@rpc("any_peer", "call_local", "reliable")
func _debug_respawn_peer(peer_id: int, new_role: String) -> void:
	if not multiplayer.is_server():
		return
	
	player_roles[peer_id] = new_role
	
	# Find node by authority instead of name
	var respawn_pos = Vector3.ZERO
	var world = get_tree().root.get_node("World")
	if world:
		for child in world.get_children():
			if child is CharacterBody3D and child.get_multiplayer_authority() == peer_id:
				respawn_pos = child.global_position
				break
	
	_remove_player(peer_id)
	spawner.spawn({"id": peer_id, "position": respawn_pos, "role": new_role})
