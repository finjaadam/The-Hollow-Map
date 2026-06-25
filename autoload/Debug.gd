extends Node

# Rune minigame scene
var rune_minigame_scene = preload("res://ui/screens/minigames/rune minigame/runeMinigame.tscn")
var rune_minigame_instance: Control = null

# Store previous mouse mode and pause state to restore when closing
var previous_mouse_mode: int = Input.MOUSE_MODE_VISIBLE
var previous_pause_state: bool = false

# Flag to track if we caused the pause
var minigame_caused_pause: bool = false


func _ready() -> void:
	# Set process input to true so we can receive input events
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	# Open/close rune minigame when 'r' key is pressed
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			# Prevent the key from being handled by other nodes
			get_viewport().set_input_as_handled()
			
			if rune_minigame_instance == null:
				_open_rune_minigame()
			else:
				_close_rune_minigame()


func _open_rune_minigame() -> void:
	print("Opening rune minigame...")
	
	# Store the current mouse mode and pause state
	previous_mouse_mode = Input.mouse_mode
	previous_pause_state = SceneLoader.is_paused
	
	# Pause the game so player can't move in background
	# Set our flag to indicate we caused the pause
	minigame_caused_pause = true
	SceneLoader.is_paused = true
	get_tree().paused = true
	
	# Create a new instance of the rune minigame
	rune_minigame_instance = rune_minigame_scene.instantiate() as Control
	
	# Connect to tree_exited signal to clean up when closed
	rune_minigame_instance.connect("tree_exited", _on_minigame_closed)
	
	# Add it to the current scene or root
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene is Control:
		current_scene.add_child(rune_minigame_instance)
	else:
		# If current scene is not a Control, add to root
		get_tree().root.add_child(rune_minigame_instance)
	
	print("Rune minigame opened")


func _close_rune_minigame() -> void:
	print("Closing rune minigame...")
	if rune_minigame_instance != null:
		# Ensure tree_exited signal is connected
		if not rune_minigame_instance.is_connected("tree_exited", _on_minigame_closed):
			rune_minigame_instance.connect("tree_exited", _on_minigame_closed)
		rune_minigame_instance.queue_free()
		print("Rune minigame closed")


func _on_minigame_closed() -> void:
	# Clear the reference and restore mouse mode and pause state when the minigame is freed
	
	# Restore the previous mouse mode
	Input.mouse_mode = previous_mouse_mode
	
	# Unpause the game if we were the ones who paused it
	if minigame_caused_pause:
		SceneLoader.is_paused = previous_pause_state
		get_tree().paused = previous_pause_state
		minigame_caused_pause = false
	
	if rune_minigame_instance != null:
		rune_minigame_instance = null
		print("Rune minigame instance cleared, mouse mode and pause state restored")


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
