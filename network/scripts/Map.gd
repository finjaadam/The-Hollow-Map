extends Node3D

@export var spawn_exit_door_points : Node3D

var spawn_exit_door_first_index: int
var spawn_exit_door_second_index: int

var exit_door_scene = preload("res://network/testEnvironment/ExitDoor.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TeamProperties.reset()
	
	# get_children() gives back a const array => to remove a value from the array we need the second variable
	var spawn_exit_door_points_dynamic = spawn_exit_door_points.get_children()
	
	# spawn first door
	spawn_exit_door_first_index = randi() % spawn_exit_door_points_dynamic.size()
	spawn_exit(spawn_exit_door_points_dynamic[spawn_exit_door_first_index])
	
	# spawn second door at a different point than the first one
	spawn_exit_door_points_dynamic.remove_at(spawn_exit_door_first_index)
	spawn_exit_door_second_index = randi() % spawn_exit_door_points_dynamic.size()
	spawn_exit(spawn_exit_door_points_dynamic[spawn_exit_door_second_index])
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_exit(doorPosition: Marker3D) -> void:
	var exit_door_scene_instance = exit_door_scene.instantiate()
	self.add_child(exit_door_scene_instance)
	exit_door_scene_instance.global_position = doorPosition.global_position
	


func _on_removes_lives_timer_timeout() -> void:
	TeamProperties.remove_one_live()
