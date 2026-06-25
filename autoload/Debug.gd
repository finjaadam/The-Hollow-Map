extends Node

# Rune minigame scene
var rune_minigame_scene = preload("res://ui/screens/minigames/rune minigame/runeMinigame.tscn")
var rune_minigame_instance: Control = null


func _ready() -> void:
	# Set process input to true so we can receive input events
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	# Open/close rune minigame when 'r' key is pressed
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			# Prevent the key from being handled by other nodes
			get_viewport().set_input_as_handled()
			
			if rune_minigame_instance == null:
				_open_rune_minigame()
			else:
				_close_rune_minigame()


func _open_rune_minigame() -> void:
	print("Opening rune minigame...")
	
	# Create a new instance of the rune minigame
	rune_minigame_instance = rune_minigame_scene.instantiate() as Control
	
	# Add it to the current scene or root
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene is Control:
		current_scene.add_child(rune_minigame_instance)
	else:
		# If current scene is not a Control, add to root
		get_tree().root.add_child(rune_minigame_instance)
		# Make sure it covers the whole screen
		rune_minigame_instance.anchor_right = 1.0
		rune_minigame_instance.anchor_bottom = 1.0
	
	print("Rune minigame opened")


func _close_rune_minigame() -> void:
	print("Closing rune minigame...")
	if rune_minigame_instance != null:
		# Connect to tree_exited signal to clear the reference when freed
		rune_minigame_instance.connect("tree_exited", _on_minigame_closed)
		rune_minigame_instance.queue_free()
	print("Rune minigame closed")


func _on_minigame_closed() -> void:
	# Clear the reference when the minigame is freed
	if rune_minigame_instance != null:
		rune_minigame_instance = null
		print("Rune minigame instance cleared")


func print_bus_order() -> void:
	print("=== Audio Bus Order ===")
	for i in range(AudioServer.get_bus_count()):
		var bus_name = AudioServer.get_bus_name(i)
		var send = AudioServer.get_bus_send(i)
		var send_str = String(send) if send != "" else "none (master)"
		print("[%d] %s  →  %s" % [i, bus_name, send_str])
	print("=======================")
