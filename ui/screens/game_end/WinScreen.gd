extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_lobby_button_pressed() -> void:
	# Reset game state but keep connection
	GameManager.clear()
	
	# Reset ready states for all players
	NetworkManager.ready_states.clear()
	
	# Go back to lobby
	SceneLoader.goto_scene("res://ui/screens/menu/lobby/lobby.tscn")
	NetworkManager.lobby_updated.emit()
	NetworkManager.lobby_name_updated.emit()


func _on_main_menu_button_pressed() -> void:
	GameManager.clear()
	NetworkManager.leave_lobby()
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn")
