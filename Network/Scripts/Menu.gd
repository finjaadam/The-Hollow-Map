extends Node
@onready var host_button = $host_button
@onready var join_button = $join_button
@onready var id_prompt = $id_prompt

var next_scene: PackedScene = preload("res://Network/TestEnvironment/world.tscn")

func host_and_go_to_next_scene():
	var instance = next_scene.instantiate()
	instance.init_network()
	instance.host_lobby()
	get_tree().change_scene_to_node(instance)
	
func join_and_go_to_next_scene(lobby_id: int):
	var instance = next_scene.instantiate()
	instance.init_network()
	instance.join_lobby(lobby_id)
	get_tree().change_scene_to_node(instance)

func _on_host_button_pressed():
	host_and_go_to_next_scene()

func _on_join_button_pressed():
	join_and_go_to_next_scene(id_prompt.text.to_int())

func _on_id_prompt_text_changed(new_text):
	join_button.disabled = (new_text.length() == 0)
