extends Control

@export var monster_won: bool

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Set the individual label based on player's role
	var role = GameManager.get_my_role()
	if monster_won:
		if role == "monster":
			$IndividualLabel.text = "Du hast die Spieler erwischt!"
		else:
			$IndividualLabel.text = "Ihr konntet nicht entkommen"
	else:
		if role == "monster":
			$IndividualLabel.text = "Du konntest sie nicht aufhalten!"
		else:
			$IndividualLabel.text = "Ihr seid gemeinsam entkommen!"
	
	# Connect to SceneLoader signal to know when lobby has loaded
	SceneLoader.scene_loading_finished.connect(_on_lobby_loaded)
	

func _on_lobby_button_pressed() -> void:
	# Reset game state but keep connection
	GameManager.clear()
	# Go back to lobby - will trigger scene_loading_finished
	SceneLoader.goto_scene("res://ui/screens/menu/lobby/lobby.tscn")

func _on_main_menu_button_pressed() -> void:
	GameManager.clear()
	NetworkManager.leave_lobby()
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn")
	

func _on_lobby_loaded(scene_path: String) -> void:
	# Only emit signals if lobby scene was loaded
	if scene_path == "res://ui/screens/menu/lobby/lobby.tscn":
		NetworkManager.lobby_updated.emit()
		NetworkManager.lobby_name_updated.emit()
		# Disconnect signal to prevent memory leaks
		SceneLoader.scene_loading_finished.disconnect(_on_lobby_loaded)
		queue_free()
