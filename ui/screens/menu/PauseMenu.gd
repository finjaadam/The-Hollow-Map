extends Control

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var title = $CenterContainer/VBoxContainer/Title

func _ready():
	add_to_group("translatable")
	process_mode = Node.PROCESS_MODE_ALWAYS
	if resume_button: resume_button.pressed.connect(_on_resume_pressed)
	if main_menu_button: main_menu_button.pressed.connect(_on_main_menu_pressed)
	Settings.setting_changed.connect(_on_setting_changed)
	_apply_translations()
	if resume_button: resume_button.grab_focus()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	if title: title.text = tr("PAUSE")
	if resume_button: resume_button.text = tr("RESUME")
	if main_menu_button: main_menu_button.text = tr("MAIN_MENU")

func _on_resume_pressed():
	get_tree().paused = false
	queue_free()

func _on_main_menu_pressed():
	get_tree().paused = false
	# Remove the pause menu first
	queue_free()
	# Then go to main menu (this will also clean up the game scene)
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
