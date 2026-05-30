extends Control

@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var title = $CenterContainer/VBoxContainer/Title
@onready var context = $CenterContainer/VBoxContainer/Context

func _ready():
	_setup_button_sounds()
	back_button.grab_focus()
	
func _setup_button_sounds():
	back_button.pressed.connect(MenuSoundManager.play_button_click)

func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
