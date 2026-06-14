class_name CollectableItem
extends Node3D

@onready var area: Area3D = $Area3D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		_collect_item()
		queue_free()

func _collect_item() -> void:
	# override with your item: GameManager.collect_<item>.rpc()
	pass
