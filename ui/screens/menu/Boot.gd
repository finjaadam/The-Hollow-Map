extends Control

func _ready() -> void:
	await get_tree().process_frame
	if not SteamCheck.steam_initialized:
		print("Initializing Steam Network")
		SteamCheck.steam_initialized = Steam.steamInit(480, true)
	SaveData.load_game()
	var name = SaveData.get_data("player_name")
	if name == null or name == "":
		SceneLoader.goto_scene("res://ui/screens/menu/SetName.tscn", false)
	else:
		SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
