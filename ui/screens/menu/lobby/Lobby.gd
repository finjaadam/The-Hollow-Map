extends Control

@onready var player_list = $PlayerList/PlayerEntries
@onready var start_button = $StartButton
@onready var ready_button = $ReadyCheckbox
@onready var player_entry = preload("res://ui/screens/menu/lobby/playerEntry.tscn")

var readyString: Dictionary = {"Ready": "Bereit", "NotReady": "Nicht Bereit"}

func _ready():
	# Connect to NetworkManager signals
	NetworkManager.lobby_ready_state_changed.connect(_refresh_player_list)
	NetworkManager.lobby_is_ready.connect(_on_lobby_ready)
	NetworkManager.game_starting.connect(_on_game_starting)
	NetworkManager.player_joined.connect(_refresh_player_list)
	NetworkManager.player_left.connect(_refresh_player_list)
	NetworkManager.lobby_created.connect(_refresh_player_list)
	NetworkManager.lobby_joined.connect(_refresh_player_list)
	
	# Only host sees Start button
	# start_button.visible = NetworkManager.is_host
	start_button.disabled = true

func _refresh_player_list():
	print(NetworkManager.lobby_members)
	for child in player_list.get_children():
		child.queue_free()
	for member in NetworkManager.lobby_members:
		var id = member["steam_id"]
		var ready = NetworkManager.ready_states.get(id, false)
		var player_entry_instance = player_entry.instantiate()
		player_entry_instance.get_node("PlayerName").text = member["steam_name"]
		player_entry_instance.get_node("Status").text = readyString.Ready if ready else readyString.NotReady
		player_list.add_child(player_entry_instance)

func _on_start_button_pressed():
	NetworkManager.start_game.rpc()

func _on_game_starting():
	var world = preload("res://network/testEnvironment/world.tscn")
	var instance = world.instantiate()
	NetworkManager.register_world(instance.get_node("MultiplayerSpawner"), instance.get_node("Map/PlayerSpawnPoints"))
	SceneLoader.goto_preloaded_scene(instance, "res://network/testEnvironment/world.tscn")

func _on_ready_checkbox_toggled(toggled_on: bool) -> void:
	NetworkManager.set_player_ready.rpc(toggled_on)

func _on_lobby_ready():
	start_button.disabled = false

func _on_back_button_pressed() -> void:
	NetworkManager.leave_lobby()
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn")
