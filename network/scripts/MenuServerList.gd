extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_lobby(button: Button, lobby: int):
	button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
	$CenterContainer/VBoxContainer.add_child(button)

func join_lobby(lobby: int):
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn", false)
	# Wait for menu to load, then trigger join
	SceneLoader.scene_loading_finished.connect(func(_path):
		SceneLoader.get_current_scene().join_and_go_to_next_scene(lobby)
	, CONNECT_ONE_SHOT)

func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn", false)
