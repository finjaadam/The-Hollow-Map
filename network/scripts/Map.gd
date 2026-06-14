extends Node3D

@export var spawn_exit_door_points : Node3D
@export var spawn_minigame_items_points : Node3D

const amount_pickaxes = 3
const amount_fishingrods = 3
const amount_runes = 6

var exit_door_scene = preload("res://network/testEnvironment/ExitDoor.tscn")
#var pickaxe_scene = preload("")
#var fishingrod_scene = preload("")
#var rune1_scene = preload("")
#var rune2_scene = preload("")
#var rune3_scene = preload("")

func _ready() -> void:
	spawn_two_exit_doors()
	spawn_minigame_items()

func spawn_two_exit_doors() -> void:
	# get_children() gives back a const array => to remove a value from the array we need the second variable
	var spawn_exit_door_points_dynamic = spawn_exit_door_points.get_children()
	var used_index
	# spawn first door
	used_index = randi() % spawn_exit_door_points_dynamic.size()
	_spawn_exit(spawn_exit_door_points_dynamic[used_index])
	
	# spawn second door at a different point than the first one
	spawn_exit_door_points_dynamic.remove_at(used_index)
	used_index = randi() % spawn_exit_door_points_dynamic.size()
	_spawn_exit(spawn_exit_door_points_dynamic[used_index])

func _spawn_exit(doorPosition: Marker3D) -> void:
	var exit_door_scene_instance = exit_door_scene.instantiate()
	self.add_child(exit_door_scene_instance)
	exit_door_scene_instance.global_position = doorPosition.global_position

func spawn_minigame_items() -> void:
	# get_children() gives back a const array => to remove a value from the array we need the second variable
	var spawn_minigame_items_points_dynamic = spawn_minigame_items_points.get_children()
	
	var used_index
	
	# spawn pickaxes -------------------------------------------------------------------------------
	for pickaxes in amount_pickaxes:
		used_index = randi() % spawn_minigame_items_points_dynamic.size()
		spawn_pickaxe(spawn_minigame_items_points_dynamic[used_index])
		spawn_minigame_items_points_dynamic.remove_at(used_index)

	# spawn fishing rods -------------------------------------------------------------------------------
	for fishingrods in amount_fishingrods:
		used_index = randi() % spawn_minigame_items_points_dynamic.size()
		spawn_fishingrod(spawn_minigame_items_points_dynamic[used_index])
		spawn_minigame_items_points_dynamic.remove_at(used_index)
	
	# spawn runes rods -------------------------------------------------------------------------------
	for runes in amount_fishingrods:
		used_index = randi() % spawn_minigame_items_points_dynamic.size()
		spawn_rune(spawn_minigame_items_points_dynamic[used_index])
		spawn_minigame_items_points_dynamic.remove_at(used_index)


func spawn_pickaxe(position: Marker3D) -> void:
	pass
func spawn_rune(position: Marker3D) -> void:
	pass
func spawn_fishingrod(position: Marker3D) -> void:
	pass
