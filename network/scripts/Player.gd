extends General_Player

var is_fishing := false; 

# do NOT create a _ready() function since it will overwrite the _ready from
# General_Player --> Use _on_ready() instead
func _on_ready() -> void:
	add_to_group("player")
	ownRole = Role.PLAYER

func set_fishing_mode(fishing: bool) -> void:
		is_fishing = fishing
		
		is_movement_locked = fishing
		
		if is_fishing:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			DisplayServer.window_move_to_foreground()
			Input.flush_buffered_events()
