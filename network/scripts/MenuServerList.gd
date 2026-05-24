extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_lobby(button: Button):
	$CenterContainer/VBoxContainer.add_child(button)

func _on_back_button_pressed() -> void:
	SceneLoader.goto_scene("res://network/testEnvironment/menu.tscn", false)
