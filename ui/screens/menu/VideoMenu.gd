extends Control

@onready var fullscreen_check = $CenterContainer/VBoxContainer/FullscreenRow/FullscreenCheck
@onready var resolution_dropdown = $CenterContainer/VBoxContainer/ResolutionRow/OptionButton
@onready var vsync_check = $CenterContainer/VBoxContainer/VsyncRow/VsyncCheck
@onready var loading_check = $CenterContainer/VBoxContainer/LoadingRow/LoadingCheck
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

@export var is_Pause_Menu: bool

func _ready():
	SceneLoader.paused.connect(_on_pause)
	add_to_group("main_menu")
	fullscreen_check.button_pressed = Settings.get_setting("fullscreen")
	vsync_check.button_pressed = Settings.get_setting("vsync")
	loading_check.button_pressed = Settings.get_setting("show_loading_screen")
		
	_setup_navigation()
	fullscreen_check.grab_focus()

func _setup_navigation():
	var controls = [fullscreen_check, resolution_dropdown, vsync_check, loading_check, back_button]
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
	if is_Pause_Menu:
		if ResourceLoader.exists("res://ui/screens/menu/pause/PauseMenu.tscn"):
			var back_destination: Node = load("res://ui/screens/menu/pause/PauseMenu.tscn").instantiate()
			get_tree().root.add_child(back_destination)
			queue_free()
	else:
		SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0: Settings.set_resolution(960, 540)
		1: Settings.set_resolution(1280, 720)
		2: Settings.set_resolution(1920, 1080)
		3: Settings.set_resolution(2560, 1440)
		4: Settings.set_resolution(3840, 2160)
	Settings.apply_settings()

func _on_pause(is_paused: bool):
	if is_Pause_Menu:
		SceneLoader.is_paused = true
		_on_back_button_pressed()
