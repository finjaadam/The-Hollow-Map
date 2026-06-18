extends Node3D

@export var player: Node3D

func _ready() -> void:
	if player == null:
		return
	$AnimationTree.advance_expression_base_node = player.get_path()
