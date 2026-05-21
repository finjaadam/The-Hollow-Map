extends Control

@onready var play_button = $CenterContainer/VBoxContainer/MenuButtons/PlayButton
@onready var tutorial_button = $CenterContainer/VBoxContainer/MenuButtons/TutorialButton
@onready var settings_button = $CenterContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var credits_button = $CenterContainer/VBoxContainer/MenuButtons/CreditsButton
@onready var exit_button = $CenterContainer/VBoxContainer/MenuButtons/ExitButton
@onready var game_title = $CenterContainer/VBoxContainer/GameTitle

func _ready():
	# Add to translatable group for instant language updates
	add_to_group("translatable")
	
	if play_button: play_button.pressed.connect(_on_play_pressed)
	if tutorial_button: tutorial_button.pressed.connect(_on_tutorial_pressed)
	if settings_button: settings_button.pressed.connect(_on_settings_pressed)
	if credits_button: credits_button.pressed.connect(_on_credits_pressed)
	if exit_button: exit_button.pressed.connect(_on_exit_pressed)
	
	# BR1 Fix: Connect to language changes
	Settings.setting_changed.connect(_on_setting_changed)
	
	_setup_navigation()
	_apply_translations()
	if play_button: play_button.grab_focus()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	# Fallback texts in case translations aren't loaded
	var fallbacks = {
		"MAIN_MENU_TITLE": "Hauptmenü",
		"PLAY": "Spielen", 
		"TUTORIAL": "Anleitung", 
		"SETTINGS": "Einstellungen",
		"CREDITS": "Mitwirkende",
		"EXIT": "Beenden"
	}
	
	var title_text = tr("MAIN_MENU_TITLE")
	if title_text == "MAIN_MENU_TITLE":  # Translation not found, use fallback
		title_text = fallbacks.get("MAIN_MENU_TITLE", "Hauptmenü")
	
	if game_title: game_title.text = title_text
	if play_button: play_button.text = tr("PLAY") if tr("PLAY") != "PLAY" else fallbacks.get("PLAY", "Spielen")
	if tutorial_button: tutorial_button.text = tr("TUTORIAL") if tr("TUTORIAL") != "TUTORIAL" else fallbacks.get("TUTORIAL", "Anleitung")
	if settings_button: settings_button.text = tr("SETTINGS") if tr("SETTINGS") != "SETTINGS" else fallbacks.get("SETTINGS", "Einstellungen")
	if credits_button: credits_button.text = tr("CREDITS") if tr("CREDITS") != "CREDITS" else fallbacks.get("CREDITS", "Mitwirkende")
	if exit_button: exit_button.text = tr("EXIT") if tr("EXIT") != "EXIT" else fallbacks.get("EXIT", "Beenden")

func _setup_navigation():
	if play_button and tutorial_button:
		play_button.focus_neighbor_bottom = tutorial_button.get_path()
	if tutorial_button and settings_button:
		tutorial_button.focus_neighbor_top = play_button.get_path()
		tutorial_button.focus_neighbor_bottom = settings_button.get_path()
	if settings_button and credits_button:
		settings_button.focus_neighbor_top = tutorial_button.get_path()
		settings_button.focus_neighbor_bottom = credits_button.get_path()
	if credits_button and exit_button:
		credits_button.focus_neighbor_top = settings_button.get_path()
		credits_button.focus_neighbor_bottom = exit_button.get_path()
	if exit_button:
		exit_button.focus_neighbor_top = credits_button.get_path()
		exit_button.focus_neighbor_bottom = play_button.get_path()
	if play_button:
		play_button.focus_neighbor_top = exit_button.get_path()

func _on_play_pressed():
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn", false)
	
func _on_tutorial_pressed():
	SceneLoader.goto_scene("res://ui/screens/menu/TutorialMenu.tscn", false)

func _on_settings_pressed():
	SceneLoader.goto_scene("res://ui/screens/menu/OptionsMenu.tscn", false)

func _on_credits_pressed():
	SceneLoader.goto_scene("res://ui/screens/menu/CreditsMenu.tscn", false)

func _on_exit_pressed():
	get_tree().quit()
