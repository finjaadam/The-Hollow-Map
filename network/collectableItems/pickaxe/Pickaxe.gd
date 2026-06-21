extends CollectableItem

func _ready() -> void:
	super()
	add_to_group("pickaxe")

func _collect_item() -> void:
	super()
	GameManager.collect_pickaxe.rpc()
