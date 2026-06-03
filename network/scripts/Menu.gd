extends Node
@onready var host_button = $CenterContainer/VBoxContainer/host_button
@onready var join_button = $CenterContainer/VBoxContainer/join_button
@onready var id_prompt = $CenterContainer/VBoxContainer/id_prompt
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

const next_scene_path = "res://network/testEnvironment/world.tscn"
var next_scene: PackedScene = preload(next_scene_path)
var instance

func _ready():
	add_to_group("main_menu")
	instance = next_scene.instantiate()
	_setup_navigation()
	if host_button: host_button.grab_focus()

func _setup_navigation():
	if host_button and join_button:
		host_button.focus_neighbor_bottom = join_button.get_path()
	if join_button and id_prompt:
		join_button.focus_neighbor_top = host_button.get_path()
		join_button.focus_neighbor_bottom = id_prompt.get_path()
	if id_prompt and back_button:
		id_prompt.focus_neighbor_top = join_button.get_path()
		id_prompt.focus_neighbor_bottom = back_button.get_path()
	if back_button:
		back_button.focus_neighbor_top = id_prompt.get_path()
		back_button.focus_neighbor_bottom = host_button.get_path()
		host_button.focus_neighbor_top = back_button.get_path()

func host_and_go_to_next_scene():
	SceneLoader.goto_preloaded_scene(instance, next_scene_path)
	instance.get_node("NetworkManager").host_lobby()
	
func join_and_go_to_next_scene(lobby_id: int):
	SceneLoader.goto_preloaded_scene(instance, next_scene_path)
	instance.get_node("NetworkManager").join_lobby()

func _on_host_button_pressed():
	host_and_go_to_next_scene()

func _on_join_button_pressed():
	join_and_go_to_next_scene(id_prompt.text.to_int())

func _on_id_prompt_text_changed(new_text):
	join_button.disabled = (new_text.length() == 0)
	
func _on_back_button_pressed():
	SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)

func _on_list_server_button_pressed() -> void:
	SceneLoader.goto_preloaded_scene(instance, next_scene_path)
	instance.request_lobby_list()
