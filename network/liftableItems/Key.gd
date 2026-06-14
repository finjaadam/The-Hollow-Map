extends LiftableItem

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		GameManager.collect_key.rpc()
		queue_free()
