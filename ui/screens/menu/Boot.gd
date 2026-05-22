extends Control

func _ready() -> void:
	await get_tree().process_frame
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
