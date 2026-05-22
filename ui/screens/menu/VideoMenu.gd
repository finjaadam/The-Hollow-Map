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
	fullscreen_check.button_pressed = Settings.get_setting("fullscreen")
	vsync_check.button_pressed = Settings.get_setting("vsync")
	loading_check.button_pressed = Settings.get_setting("show_loading_screen")
		
	_setup_navigation()
	fullscreen_check.grab_focus()

func _setup_navigation():
	var controls = [fullscreen_check, vsync_check, loading_check, back_button]
	for i in range(controls.size()):
		if controls[i]:
			var prev_idx = (i - 1 + controls.size()) % controls.size()
			var next_idx = (i + 1) % controls.size()
			controls[i].focus_neighbor_top = controls[prev_idx].get_path()
			controls[i].focus_neighbor_bottom = controls[next_idx].get_path()

func _on_fullscreen_check_toggled(on: bool) -> void:
	Settings.set_setting("fullscreen", on)
	Settings.apply_settings()

func _on_vsync_check_toggled(on: bool) -> void:
	Settings.set_setting("vsync", on)
	Settings.apply_settings()

func _on_loading_check_toggled(on: bool) -> void:
	Settings.set_setting("show_loading_screen", on)
	Settings.apply_settings()

func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)
