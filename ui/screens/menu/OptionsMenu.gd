extends Control

@onready var audio_button = $CenterContainer/VBoxContainer/OptionsButtons/AudioButton
@onready var video_button = $CenterContainer/VBoxContainer/OptionsButtons/VideoButton
@onready var name_button = $CenterContainer/VBoxContainer/OptionsButtons/NameButton
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

@onready var title_label = $CenterContainer/VBoxContainer/Title

func _ready():
	_setup_navigation()
	_setup_button_sounds()
	audio_button.grab_focus()

func _setup_navigation():
	var controls = [audio_button, video_button, name_button, back_button]
	for i in range(controls.size()):
		if controls[i]:
			var prev_idx = (i - 1 + controls.size()) % controls.size()
			var next_idx = (i + 1) % controls.size()
			controls[i].focus_neighbor_top = controls[prev_idx].get_path()
			controls[i].focus_neighbor_bottom = controls[next_idx].get_path()

func _setup_button_sounds():
	for button in [audio_button, video_button, name_button, back_button]:
		button.pressed.connect(MenuSoundManager.play_button_click)

func _on_audio_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/AudioMenu.tscn", false)

func _on_video_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/VideoMenu.tscn", false)

func _on_name_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/SetName.tscn", false)

func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
