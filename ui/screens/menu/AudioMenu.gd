extends Control
@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var reset_button = $CenterContainer/VBoxContainer/AudioContent/Reset

@onready var master_slider = $CenterContainer/VBoxContainer/AudioContent/HSliderMaster
@onready var music_slider = $CenterContainer/VBoxContainer/AudioContent/HSliderMusic
@onready var sfx_slider = $CenterContainer/VBoxContainer/AudioContent/HSliderSFX
@onready var chat_slider = $CenterContainer/VBoxContainer/AudioContent/HSliderChat

@onready var master_label = $CenterContainer/VBoxContainer/AudioContent/HBoxContainer/Label
@onready var music_label = $CenterContainer/VBoxContainer/AudioContent/HBoxContainer2/Label2
@onready var sfx_label = $CenterContainer/VBoxContainer/AudioContent/HBoxContainer3/Label3
@onready var chat_label = $CenterContainer/VBoxContainer/AudioContent/HBoxContainer4/Label4


@export var is_Pause_Menu: bool

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("main_menu")
	_load_audio_settings()
	_setup_navigation()
	master_slider.grab_focus()

func _setup_navigation():
	var controls = [master_slider, music_slider, sfx_slider, chat_slider, reset_button, back_button]
	for i in range(controls.size()):
		if controls[i]:
			var prev_idx = (i - 1 + controls.size()) % controls.size()
			var next_idx = (i + 1) % controls.size()
			controls[i].focus_neighbor_top = controls[prev_idx].get_path()
			controls[i].focus_neighbor_bottom = controls[next_idx].get_path()

func _load_audio_settings():
	Settings.load_settings()
	master_slider.value = Settings.get_setting("master_volume") * 100
	music_slider.value = Settings.get_setting("music_volume") * 100
	sfx_slider.value = Settings.get_setting("sfx_volume") * 100
	chat_slider.value = Settings.get_setting("chat_volume") * 100

func _on_back_button_pressed() -> void:
	Settings.apply_audio_settings()
	Settings.save_settings()
	if is_Pause_Menu:
		if ResourceLoader.exists("res://ui/screens/menu/pause/PauseMenu.tscn"):
			var back_destination: Node = load("res://ui/screens/menu/pause/PauseMenu.tscn").instantiate()
			get_tree().root.add_child(back_destination)
			queue_free()
	else:
		SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)


func _on_h_slider_master_value_changed(value: float) -> void:
	Settings.set_setting("master_volume", value / 100 )
	master_label.text = str(int(value)) + "%"
	Settings.apply_audio_settings()


func _on_h_slider_music_value_changed(value: float) -> void:
	Settings.set_setting("music_volume", value / 100 )
	music_label.text = str(int(value)) + "%"
	Settings.apply_audio_settings()


func _on_h_slider_sfx_value_changed(value: float) -> void:
	Settings.set_setting("sfx_volume", value / 100 )
	sfx_label.text = str(int(value)) + "%"
	Settings.apply_audio_settings()


func _on_h_slider_chat_value_changed(value: float) -> void:
	Settings.set_setting("chat_volume", value / 100 )
	chat_label.text = str(int(value)) + "%"
	Settings.apply_audio_settings()


func _on_reset_pressed() -> void:
	Settings.reset_audio()
	_load_audio_settings()
