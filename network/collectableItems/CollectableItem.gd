class_name CollectableItem
extends Node3D

@onready var area: Area3D = $Area3D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if not multiplayer.is_server(): 
		return
	if body.is_in_group("player"):
		_collect_item()
		queue_free()
		

func _collect_item() -> void:
	GameManager.despawn_minigame_items.rpc(self.get_groups()[0])
	# override with your item: 
		#super()
		#GameManager.collect_<item>.rpc()
	pass
