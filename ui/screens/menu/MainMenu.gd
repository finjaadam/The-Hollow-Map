extends Control

@onready var play_button = $CenterContainer/VBoxContainer/MenuButtons/PlayButton
@onready var settings_button = $CenterContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var credits_button = $CenterContainer/VBoxContainer/MenuButtons/CreditsButton
@onready var exit_button = $CenterContainer/VBoxContainer/MenuButtons/ExitButton

func _ready():
	add_to_group("main_menu")
	_setup_navigation()
	play_button.grab_focus()

func _setup_navigation():
	var controls = [play_button, settings_button, credits_button, exit_button]
	for i in range(controls.size()):
		if controls[i]:
			var prev_idx = (i - 1 + controls.size()) % controls.size()
			var next_idx = (i + 1) % controls.size()
			controls[i].focus_neighbor_top = controls[prev_idx].get_path()
			controls[i].focus_neighbor_bottom = controls[next_idx].get_path()


func _on_play_button_pressed() -> void:
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn", false)


func _on_settings_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)


func _on_credits_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/CreditsMenu.tscn", false)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
