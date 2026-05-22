extends Control

@onready var audio_button = $CenterContainer/VBoxContainer/OptionsButtons/AudioButton
@onready var video_button = $CenterContainer/VBoxContainer/OptionsButtons/VideoButton
@onready var controls_button = $CenterContainer/VBoxContainer/OptionsButtons/ControlsButton
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

@onready var title_label = $CenterContainer/VBoxContainer/Title

func _ready():
	_setup_navigation()
	audio_button.grab_focus()

func _setup_navigation():
	var controls = [audio_button, video_button, controls_button, back_button]
	for i in range(controls.size()):
		if controls[i]:
			var prev_idx = (i - 1 + controls.size()) % controls.size()
			var next_idx = (i + 1) % controls.size()
			controls[i].focus_neighbor_top = controls[prev_idx].get_path()
			controls[i].focus_neighbor_bottom = controls[next_idx].get_path()

func _on_audio_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/AudioMenu.tscn", false)

func _on_video_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/VideoMenu.tscn", false)

func _on_controls_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/ControlsMenu.tscn", false)

func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
