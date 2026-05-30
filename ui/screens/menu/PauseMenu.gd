extends Control

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var title = $CenterContainer/VBoxContainer/Title

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_button_sounds()
	resume_button.grab_focus()

func _setup_button_sounds():
	for button in [resume_button, main_menu_button]:
		button.pressed.connect(MenuSoundManager.play_button_click)

func _on_resume_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	queue_free()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	
	# Find networking node and leave lobby before changing scene
	var world = SceneLoader.get_current_scene()
	if is_instance_valid(world):
		world.leave_lobby()
	
	queue_free()
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
