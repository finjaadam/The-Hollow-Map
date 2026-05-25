extends Control

@onready var text_field = $CenterContainer/VBoxContainer/NameField
@onready var warning = $CenterContainer/VBoxContainer/Warning
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_field.text = SaveData.get_data("player_name", "")
	if text_field.text != "":
		back_button.visible = true
	text_field.text = Steam.getPersonaName()
	text_field.caret_column = text_field.text.length()
	text_field.grab_focus()


func _on_accept_pressed() -> void:
	if text_field.text.length() < 4:
		warning.visible = true
		text_field.caret_column = text_field.text.length()
		text_field.grab_focus()
	else:
		SaveData.set_data("player_name", text_field.text)
		SaveData.save_game()
		if back_button.visible == true:
			SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)
		else:
			SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)


func _on_name_field_text_submitted(new_text: String) -> void:
	_on_accept_pressed()

func _on_name_field_text_changed(new_text: String) -> void:
	warning.visible = false

func _on_name_field_text_change_rejected(rejected_substring: String) -> void:
	warning.visible = true

func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)
