extends Node3D

@export var spawn_exit_door_points : Node3D
@export var spawn_minigame_items_points : Node3D


const amount_exits = 2
# items can not be lost when they got collected
# for three pickaxe-minigames, we would still just need one pickaxe
# however for balancing reasons there are more items of each type
const amount_pickaxes = 2
const amount_fishingrods = 2
const amount_runes = 6

var exit_door_scene = preload("res://network/testEnvironment/ExitDoor.tscn")
var pickaxe_scene = preload("res://network/collectableItems/pickaxe/pickaxe.tscn")
var fishingrod_scene = preload("res://network/collectableItems/fishingrod/fishingrod.tscn")
var rune_scene = preload("res://network/collectableItems/rune/rune.tscn")
var trap_scene = preload("res://network/monster/abilities/trap/monster_trap.tscn")

func _ready() -> void:
	GameManager.spawn_added.connect(_on_spawn_added)
	
	if not multiplayer.is_server(): 
		return
	
	spawn_exit_doors()
	spawn_minigame_items()
func _on_spawn_added(position: Vector3, type: GameManager.spawn_type) -> void:
	match type:
		GameManager.spawn_type.DOOR:
			spawn_exit(position)
		GameManager.spawn_type.PICKAXE:
			spawn_pickaxe(position)
		GameManager.spawn_type.FISHINGROD:
			spawn_fishingrod(position)
		GameManager.spawn_type.RUNE:
			spawn_rune(position)
		GameManager.spawn_type.TRAP:
			spawn_trap(position)

func spawn_exit_doors() -> void:
	# get_children() gives back a const array => to remove a value from the array we need the second variable
	var spawn_exit_door_points_dynamic = spawn_exit_door_points.get_children()
	var used_index
	
	for doors in amount_exits:
		used_index = randi() % spawn_exit_door_points_dynamic.size()
		GameManager.add_spawn.rpc(spawn_exit_door_points_dynamic[used_index].global_position, GameManager.spawn_type.DOOR)
		spawn_exit_door_points_dynamic.remove_at(used_index)

func spawn_exit(doorPosition: Vector3) -> void:
	var exit_door_scene_instance = exit_door_scene.instantiate()
	self.add_child(exit_door_scene_instance)
	exit_door_scene_instance.global_position = doorPosition
	

func spawn_minigame_items() -> void:
	# get_children() gives back a const array => to remove a value from the array we need the second variable
	var spawn_minigame_items_points_dynamic = spawn_minigame_items_points.get_children()
	var used_index
	
	# spawn pickaxes -------------------------------------------------------------------------------
	for pickaxes in amount_pickaxes:
		used_index = randi() % spawn_minigame_items_points_dynamic.size()
		GameManager.add_spawn.rpc(spawn_minigame_items_points_dynamic[used_index].global_position, GameManager.spawn_type.PICKAXE)
		spawn_minigame_items_points_dynamic.remove_at(used_index)

	# spawn fishing rods -------------------------------------------------------------------------------
	for fishingrods in amount_fishingrods:
		used_index = randi() % spawn_minigame_items_points_dynamic.size()
		GameManager.add_spawn.rpc(spawn_minigame_items_points_dynamic[used_index].global_position, GameManager.spawn_type.FISHINGROD)
		spawn_minigame_items_points_dynamic.remove_at(used_index)
	
	# spawn runes rods -------------------------------------------------------------------------------
	for runes in amount_runes:
		used_index = randi() % spawn_minigame_items_points_dynamic.size()
		GameManager.add_spawn.rpc(spawn_minigame_items_points_dynamic[used_index].global_position, GameManager.spawn_type.RUNE)
		spawn_minigame_items_points_dynamic.remove_at(used_index)


func spawn_pickaxe(position: Vector3) -> void:
	var pickaxe_scene_instance = pickaxe_scene.instantiate()
	self.add_child(pickaxe_scene_instance)
	pickaxe_scene_instance.global_position = position

func spawn_fishingrod(position: Vector3) -> void:
	var fishingrod_scene_instance = fishingrod_scene.instantiate()
	self.add_child(fishingrod_scene_instance)
	fishingrod_scene_instance.global_position = position

func spawn_rune(position: Vector3) -> void:
	var rune_scene_instance = rune_scene.instantiate()
	self.add_child(rune_scene_instance)
	rune_scene_instance.global_position = position

func spawn_trap(position: Vector3) -> void:
	var trap_scene_instance = trap_scene.instantiate()
	self.add_child(trap_scene_instance)
	trap_scene_instance.global_position = position
