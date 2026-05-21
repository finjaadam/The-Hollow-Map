extends Control

@onready var new_game_button = $CenterContainer/VBoxContainer/GameButtons/NewGameButton
@onready var continue_button = $CenterContainer/VBoxContainer/GameButtons/ContinueButton
@onready var level_select_button = $CenterContainer/VBoxContainer/GameButtons/LevelSelectButton
@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var title = $CenterContainer/VBoxContainer/GameTitle

func _ready():
	# Add to translatable group for instant language updates
	add_to_group("translatable")
	
	if new_game_button: new_game_button.pressed.connect(_on_new_game_pressed)
	if continue_button: continue_button.pressed.connect(_on_continue_pressed)
	if level_select_button: level_select_button.pressed.connect(_on_level_select_pressed)
	if back_button: back_button.pressed.connect(_on_back_pressed)
	
	# BR1 Fix: Connect to language changes
	Settings.setting_changed.connect(_on_setting_changed)
	
	_setup_navigation()
	_apply_translations()
	if SaveData.has_save_file():
		if continue_button:
			continue_button.disabled = false
			continue_button.grab_focus()
	else:
		if continue_button:
			continue_button.disabled = true
		if new_game_button:
			new_game_button.grab_focus()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _apply_translations():
	if title: title.text = tr("PLAY")
	if new_game_button: new_game_button.text = tr("NEW_GAME")
	if continue_button: continue_button.text = tr("CONTINUE")
	if level_select_button: level_select_button.text = tr("LEVEL_SELECT")
	if back_button: back_button.text = tr("BACK")

func _setup_navigation():
	var buttons = [new_game_button, continue_button, level_select_button, back_button]
	for i in range(buttons.size()):
		if buttons[i]:
			var prev_idx = (i - 1 + buttons.size()) % buttons.size()
			var next_idx = (i + 1) % buttons.size()
			buttons[i].focus_neighbor_top = buttons[prev_idx].get_path()
			buttons[i].focus_neighbor_bottom = buttons[next_idx].get_path()

func _on_new_game_pressed():
	# CR1: Changed from Level1.tscn to playgame.tscn
	if ResourceLoader.exists("res://game/playgame.tscn"):
		SceneLoader.goto_scene("res://game/playgame.tscn")
	else:
		print("Create res://game/playgame.tscn for your main game scene!")

func _on_continue_pressed():
	if SaveData.load_game():
		# CR1: Changed to go to main game scene instead of specific level
		if ResourceLoader.exists("res://game/playgame.tscn"):
			SceneLoader.goto_scene("res://game/playgame.tscn")
		else:
			print("Game scene not found: res://game/playgame.tscn")

func _on_level_select_pressed():
	print("Level select screen - implement your level selection here!")

func _on_back_pressed():
	SceneLoader.goto_scene("res://ui/screens/MainMenu.tscn", false)
