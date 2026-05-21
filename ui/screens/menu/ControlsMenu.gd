extends Control
@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var title = $CenterContainer/VBoxContainer/Title

func _ready():
	add_to_group("translatable")
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		back_button.grab_focus()
	Settings.setting_changed.connect(_on_setting_changed)
	_apply_translations()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	if title: title.text = tr("TUTORIAL")
	if back_button: back_button.text = tr("BACK")

func _on_back_pressed():
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
