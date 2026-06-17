extends Node

func print_bus_order() -> void:
	print("=== Audio Bus Order ===")
	for i in range(AudioServer.get_bus_count()):
		var bus_name = AudioServer.get_bus_name(i)
		var send = AudioServer.get_bus_send(i)
		var send_str = String(send) if send != "" else "none (master)"
		print("[%d] %s  →  %s" % [i, bus_name, send_str])
	print("=======================")
	
# --- Debug Functions ---

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_players_won"):
		_debug_players_won()
	elif event.is_action_pressed("debug_monster_won"):
		_debug_monster_won()

# Debug function to manually trigger players won (P)
func _debug_players_won() -> void:
	GameManager.end_game.rpc(true)
	print("DEBUG: Players won triggered via P")

# Debug function to manually trigger monster won (M)
func _debug_monster_won() -> void:
	GameManager.end_game.rpc(false)
	print("DEBUG: Monster won triggered via M")
