extends Control

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var title = $CenterContainer/VBoxContainer/Title

func _ready():
	SceneLoader.paused.connect(_on_pause)
	resume_button.grab_focus()
	MenuSoundManager.connect_button_sounds(self)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_button_pressed() -> void:
	SceneLoader.toggle_pause()
		
func _on_pause(is_paused: bool):
	if not is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		queue_free()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	
	# Find networking node and leave lobby before changing scene
	var world = SceneLoader.get_current_scene()
	if is_instance_valid(world):
		NetworkManager.leave_lobby()
	
	queue_free()
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)


func _on_audio_button_pressed() -> void:
	if ResourceLoader.exists("res://ui/screens/menu/pause/AudioMenu.tscn"):
		var audio_menu: Node = load("res://ui/screens/menu/pause/AudioMenu.tscn").instantiate()
		get_tree().current_scene.add_child(audio_menu)
		SceneLoader.scene_loading_finished.emit("res://ui/screens/menu/pause/AudioMenu.tscn")
		queue_free()


func _on_video_button_pressed() -> void:
	if ResourceLoader.exists("res://ui/screens/menu/pause/VideoMenu.tscn"):
		var video_menu: Node = load("res://ui/screens/menu/pause/VideoMenu.tscn").instantiate()
		get_tree().current_scene.add_child(video_menu)
		SceneLoader.scene_loading_finished.emit("res://ui/screens/menu/pause/VideoMenu.tscn")
		queue_free()
