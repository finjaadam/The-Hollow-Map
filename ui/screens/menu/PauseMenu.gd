extends Control

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var title = $CenterContainer/VBoxContainer/Title

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.grab_focus()

func _on_resume_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	queue_free()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
