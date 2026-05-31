extends Control

@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var title = $CenterContainer/VBoxContainer/Title
@onready var context = $CenterContainer/VBoxContainer/Context

func _ready():
	add_to_group("main_menu")
	back_button.grab_focus()
	
func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
