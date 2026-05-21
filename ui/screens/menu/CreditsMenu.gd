extends Control

@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var title = $CenterContainer/VBoxContainer/Title
@onready var context = $CenterContainer/VBoxContainer/Context

func _ready():
	# Add to translatable group for instant language updates
	add_to_group("translatable")
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
		back_button.grab_focus()
	
	# BR1 Fix: Connect to language changes
	Settings.setting_changed.connect(_on_setting_changed)
	
	_apply_translations()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	if title: title.text = tr("CREDITS")
	if back_button: back_button.text = tr("BACK")
	if context: context.text = tr("CONTEXT")

func _on_back_pressed():
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
