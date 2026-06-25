extends Control

# Rune minigame script
# Features:
# - 3 runes on the right, 3 slots on the left
# - Runes are draggable
# - Each rune has a randomly assigned correct slot
# - Wrong placement resets all runes
# - All correct placements = win

# Signal to inform the main game when the minigame is finished
signal game_finished(success: bool)

# Sound for mistakes
const ERROR_SOUND = preload("res://network/monster/abilities/trap/trap_sound.mp3")
var error_sound_player: AudioStreamPlayer

# Node references
@onready var rune1 = $Background/MainHBox/VBoxContainer2/Rune1
@onready var rune2 = $Background/MainHBox/VBoxContainer2/Rune2
@onready var rune3 = $Background/MainHBox/VBoxContainer2/Rune3

@onready var slot1 = $Background/MainHBox/VBoxContainer3/HBoxContainer2/Slot1
@onready var slot2 = $Background/MainHBox/VBoxContainer3/HBoxContainer2/Slot2
@onready var slot3 = $Background/MainHBox/VBoxContainer3/HBoxContainer2/Slot3

# Ghost rune references (faint images in slots)
@onready var ghost_rune1 = $Background/MainHBox/VBoxContainer3/HBoxContainer2/Slot1/GhostRune1
@onready var ghost_rune2 = $Background/MainHBox/VBoxContainer3/HBoxContainer2/Slot2/GhostRune2
@onready var ghost_rune3 = $Background/MainHBox/VBoxContainer3/HBoxContainer2/Slot3/GhostRune3

# Array of ghost runes for easier management
var ghost_runes = []

# Game state
var runes = []
var slots = []
var game_active = false

# Mapping: which rune (index) belongs in which slot (index)
var correct_mapping = []

# Track which rune is currently being dragged
var dragged_rune = null
var dragged_rune_index = -1
var drag_offset = Vector2.ZERO

# Track which runes are currently placed in slots (rune_index -> slot_index)
var placed_runes = {}

# Original positions of runes
var original_rune_positions = []

# Game state
var game_won = false

# Pause state tracking
var was_paused = false


func _ready() -> void:
	# Enable input processing
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Setup error sound player
	error_sound_player = AudioStreamPlayer.new()
	error_sound_player.bus = "SFX"
	error_sound_player.name = "ErrorSoundPlayer"
	add_child(error_sound_player)
	
	# Initialize arrays
	runes = [rune1, rune2, rune3]
	slots = [slot1, slot2, slot3]
	ghost_runes = [ghost_rune1, ghost_rune2, ghost_rune3]
	
	# Enable mouse input for runes
	for i in range(3):
		runes[i].mouse_filter = Control.MOUSE_FILTER_STOP
		# Connect gui_input signal for each rune
		runes[i].gui_input.connect(_on_rune_gui_input.bind(i))
	
	# Setup slots to accept drops
	for i in range(3):
		slots[i].mouse_filter = Control.MOUSE_FILTER_STOP
		slots[i].gui_input.connect(_on_slot_gui_input.bind(i))
	
	# Connect to SceneLoader pause signal
	SceneLoader.paused.connect(_on_pause_toggled)
	
	# Generate random correct mapping
	_generate_random_mapping()
	
	# Setup ghost runes based on correct mapping
	_update_ghost_runes()
	
	# Wait for layout to complete, then store positions
	await get_tree().process_frame
	# Store original global positions after layout
	for i in range(3):
		original_rune_positions.append(runes[i].global_position)
	
	# Start the game
	start_game()


func start_game() -> void:
	game_active = true
	game_won = false
	
	# Reset game state
	reset_game()
	
	# Set mouse to visible for the minigame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _generate_random_mapping() -> void:
	# Create an array of slot indices [0, 1, 2]
	var available_slots = [0, 1, 2]
	
	# Shuffle the array to assign random slots to runes
	available_slots.shuffle()
	
	# Assign each rune to a shuffled slot
	for rune_idx in range(3):
		correct_mapping.append(available_slots[rune_idx])
	
	print("Correct mapping: Rune 0 -> Slot ", correct_mapping[0], ", Rune 1 -> Slot ", correct_mapping[1], ", Rune 2 -> Slot ", correct_mapping[2])


func _on_pause_toggled(is_paused: bool) -> void:
	if not is_paused and game_active:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _update_ghost_runes() -> void:
	# Update ghost rune textures based on correct mapping
	# Each ghost rune should show the texture of the rune that belongs in that slot
	for slot_idx in range(3):
		# Find which rune belongs in this slot
		var rune_idx_for_slot = -1
		for rune_idx in range(3):
			if correct_mapping[rune_idx] == slot_idx:
				rune_idx_for_slot = rune_idx
				break
			
		if rune_idx_for_slot != -1:
			# Set the ghost rune texture to match the rune that belongs here
			ghost_runes[slot_idx].texture = runes[rune_idx_for_slot].texture
			ghost_runes[slot_idx].visible = true


func reset_game() -> void:
	# Reset game state
	game_won = false
	placed_runes.clear()
	
	# Return all runes to original positions
	for i in range(3):
		var rune = runes[i]
		# Make sure rune is in the right parent
		if rune.get_parent() != $Background/MainHBox/VBoxContainer2:
			$Background/MainHBox/VBoxContainer2.add_child(rune)
			
		# Reset to original global position
		rune.global_position = original_rune_positions[i]
		rune.visible = true
		rune.mouse_filter = Control.MOUSE_FILTER_STOP
		rune.self_modulate = Color(1, 1, 1, 1)  # Restore full opacity
		
	# Clear slots
	for i in range(3):
		slots[i].self_modulate = Color(1, 1, 1, 1)  # Reset color
	
	# Generate new random mapping
	correct_mapping.clear()
	_generate_random_mapping()
	
	# Update ghost runes with new mapping
	_update_ghost_runes()
	
	# Show ghost runes
	for i in range(3):
		ghost_runes[i].visible = true


func _on_rune_gui_input(event: InputEvent, rune_idx: int) -> void:
	var rune = runes[rune_idx]
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Start drag
			dragged_rune = rune
			dragged_rune_index = rune_idx
			drag_offset = rune.global_position - get_global_mouse_position()
			
			# Hide ghost runes on first grab
			for i in range(3):
				ghost_runes[i].visible = false
			
			# Bring rune to front (higher z-index) while dragging
			rune.self_modulate.a = 0.8  # Make slightly transparent
			
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if dragged_rune == rune:
				# End drag
				rune.self_modulate.a = 1.0  # Restore opacity
				
				# Check if we dropped on a valid slot
				var mouse_pos = get_global_mouse_position()
				var dropped_on_slot = -1
				
				for i in range(3):
					if slots[i].get_global_rect().has_point(mouse_pos):
						dropped_on_slot = i
						break
					
				if dropped_on_slot != -1:
					_on_drop_rune_on_slot(rune_idx, dropped_on_slot)
				else:
					# Dropped elsewhere, return to original position
					rune.global_position = original_rune_positions[rune_idx]
					
				dragged_rune = null
				dragged_rune_index = -1


func _on_slot_gui_input(event: InputEvent, slot_idx: int) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if dragged_rune != null:
			# Find which rune is being dragged
			for rune_idx in range(3):
				if runes[rune_idx] == dragged_rune:
					_on_drop_rune_on_slot(rune_idx, slot_idx)
					break


func _on_drop_rune_on_slot(rune_idx: int, slot_idx: int) -> void:
	print("Dropping rune ", rune_idx, " on slot ", slot_idx)
	
	# Check if this slot already has a rune placed in it
	for existing_rune_idx in placed_runes:
		if placed_runes[existing_rune_idx] == slot_idx:
			# This slot is already occupied, return to original position
			var rune = runes[rune_idx]
			rune.global_position = original_rune_positions[rune_idx]
			dragged_rune = null
			dragged_rune_index = -1
			return
	
	# Check if this is the correct slot for this rune
	if correct_mapping[rune_idx] == slot_idx:
		# Correct placement!
		print("Correct! Rune ", rune_idx, " belongs in slot ", slot_idx)
		
		# Move the rune to the slot's position
		var rune = runes[rune_idx]
		rune.global_position = slots[slot_idx].global_position
		
		# Mark as placed
		placed_runes[rune_idx] = slot_idx
		
		# Change slot color to indicate correct placement
		slots[slot_idx].self_modulate = Color(0, 1, 0, 1)  # Green
		
		# Disable dragging for placed rune
		rune.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Check if all runes are placed correctly
		if placed_runes.size() == 3:
			game_won = true
			print("You win!")
			_on_game_won()
			
	else:
		# Wrong placement - reset all runes
		print("Wrong! Rune ", rune_idx, " doesn't belong in slot ", slot_idx)
		# Play error sound
		error_sound_player.stream = ERROR_SOUND
		error_sound_player.play()
		reset_game()
	
	dragged_rune = null
	dragged_rune_index = -1


func _on_game_won() -> void:
	print("Game won!")
	game_active = false
	game_finished.emit(true)
	# Give control back
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	# If we're dragging a rune, move it with the mouse
	if dragged_rune != null:
		dragged_rune.global_position = get_global_mouse_position() + drag_offset


func _unhandled_input(event: InputEvent) -> void:
	# Close the minigame when ESC is pressed
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		# Emit failure signal before closing
		game_finished.emit(false)
		queue_free()


func _exit_tree() -> void:
	# Clean up when the minigame is closed
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Public function to reset the game
func reset() -> void:
	reset_game()
