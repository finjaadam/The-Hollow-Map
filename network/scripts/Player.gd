extends General_Player

# do NOT create a _ready() function since it will overwrite the _ready from
# General_Player --> Use _on_ready() instead
func _on_ready() -> void:
	add_to_group("player")
	ownRole = Role.PLAYER

func _handle_animations(direction: Vector3) -> void:
	if animation_player: 
		if direction != Vector3.ZERO:
			if animation_player.current_animation != "Sneak_Walk/mixamo_com":
				animation_player.play("Sneak_Walk/mixamo_com")
		else:
			animation_player.stop()
