extends Node

func _ready() -> void:
	# Set process input to true so we can receive input events
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	# Open rune minigame when 'r' key is pressed
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			# Prevent the key from being handled by other nodes
			get_viewport().set_input_as_handled()
			_open_rune_minigame()


func _open_rune_minigame() -> void:
	print("Opening rune minigame...")		
	# Create a new instance of the rune minigame
	var rune_minigame_instance = preload("res://ui/screens/minigames/rune minigame/runeMinigame.tscn").instantiate() as Control
	get_tree().root.add_child(rune_minigame_instance)
	print("Rune minigame opened")	


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
	if OS.is_debug_build():
		if event.is_action_pressed("debug_players_won"):
			_debug_players_won()
		elif event.is_action_pressed("debug_monster_won"):
			_debug_monster_won()
		elif event.is_action_pressed("DEBUG_STOP_WIN_CONDITION_CHECK"):
			GameManager.stop_life_drain()

# Debug function to manually trigger players won (P)
func _debug_players_won() -> void:
	GameManager.end_game.rpc(true)
	print("DEBUG: Players won triggered via P")

# Debug function to manually trigger monster won (M)
func _debug_monster_won() -> void:
	GameManager.end_game.rpc(false)
	print("DEBUG: Monster won triggered via M")
