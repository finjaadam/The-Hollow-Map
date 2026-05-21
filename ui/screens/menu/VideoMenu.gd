extends Control

@onready var fullscreen_check = $CenterContainer/VBoxContainer/FullscreenRow/FullscreenCheck
@onready var vsync_check = $CenterContainer/VBoxContainer/VsyncRow/VsyncCheck
@onready var loading_check = $CenterContainer/VBoxContainer/LoadingRow/LoadingCheck
@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var title = $CenterContainer/VBoxContainer/Title
@onready var fullscreen_label = $CenterContainer/VBoxContainer/FullscreenRow/FullscreenLabel
@onready var vsync_label = $CenterContainer/VBoxContainer/VsyncRow/VsyncLabel
@onready var loading_label = $CenterContainer/VBoxContainer/LoadingRow/LoadingLabel

func _ready():
	add_to_group("translatable")
	if fullscreen_check:
		fullscreen_check.button_pressed = Settings.get_setting("fullscreen")
		fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	if vsync_check:
		vsync_check.button_pressed = Settings.get_setting("vsync")
		vsync_check.toggled.connect(_on_vsync_toggled)
	if loading_check:
		loading_check.button_pressed = Settings.get_setting("show_loading_screen")
		loading_check.toggled.connect(_on_loading_screen_toggled)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	Settings.setting_changed.connect(_on_setting_changed)
	_setup_navigation()
	_apply_translations()
	if fullscreen_check:
		fullscreen_check.grab_focus()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	if title: title.text = tr("VIDEO_SETTINGS")
	if fullscreen_label: fullscreen_label.text = tr("FULLSCREEN")
	if vsync_label: vsync_label.text = tr("VSYNC")
	if loading_label: loading_label.text = tr("SHOW_LOADING_SCREEN")
	if back_button: back_button.text = tr("BACK")

func _setup_navigation():
	var controls = [fullscreen_check, vsync_check, loading_check, back_button]
	for i in range(controls.size()):
		if controls[i]:
			var prev_idx = (i - 1 + controls.size()) % controls.size()
			var next_idx = (i + 1) % controls.size()
			controls[i].focus_neighbor_top = controls[prev_idx].get_path()
			controls[i].focus_neighbor_bottom = controls[next_idx].get_path()

func _on_fullscreen_toggled(pressed: bool):
	Settings.set_setting("fullscreen", pressed)
	Settings.apply_settings()

func _on_vsync_toggled(pressed: bool):
	Settings.set_setting("vsync", pressed)
	Settings.apply_settings()

func _on_loading_screen_toggled(pressed: bool):
	Settings.set_setting("show_loading_screen", pressed)
	Settings.apply_settings()

func _on_back_pressed():
	SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)
