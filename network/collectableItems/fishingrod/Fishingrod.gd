extends CollectableItem

func _ready() -> void:
	super()
	add_to_group("fishingrod")

func _collect_item() -> void:
	super()
	GameManager.collect_fishingrod.rpc()
