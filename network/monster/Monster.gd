extends General_Player

# do NOT create a _ready() function since it will overwrite the _ready from
# General_Player --> Use _on_ready() instead
func _on_ready() -> void:
	add_to_group("monster")
	ownRole = Role.MONSTER
