extends LiftableItem

func _collect_item() -> void:
	GameManager.collect_key.rpc()
