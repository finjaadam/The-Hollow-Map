extends Control

func _ready():
	# Connect return button if it exists
	if has_node("ReturnButton"):
		$ReturnButton.pressed.connect(_on_return_to_lobby_pressed)

func _on_return_to_lobby_pressed():
	# Reset game state but keep connection
	GameManager.clear()
	
	# Reset ready states for all players
	NetworkManager.ready_states.clear()
	for member in NetworkManager.lobby_members:
		NetworkManager.ready_states[member["steam_id"]] = false
	NetworkManager.lobby_updated.emit()
	
	# Go back to lobby
	SceneLoader.goto_scene("res://ui/screens/menu/lobby/lobby.tscn")