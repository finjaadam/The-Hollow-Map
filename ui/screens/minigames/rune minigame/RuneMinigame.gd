extends Control

# Rune minigame script
# Features:
# - 3 runes on the right, 3 slots on the left
# - Runes are draggable
# - Each rune has a randomly assigned correct slot
# - Wrong placement resets all runes
# - All correct placements = win

# Node references
@onready var rune1 = $ColorRect2/VBoxContainer2/Rune1
@onready var rune2 = $ColorRect2/VBoxContainer2/Rune2
@onready var rune3 = $ColorRect2/VBoxContainer2/Rune3

@onready var slot1 = $ColorRect/VBoxContainer3/HBoxContainer2/Slot1
@onready var slot2 = $ColorRect/VBoxContainer3/HBoxContainer2/Slot2
@onready var slot3 = $ColorRect/VBoxContainer3/HBoxContainer2/Slot3

# Game state
var runes = []
var slots = []

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

# Signal for when the game is won
signal game_won_signal


func _ready() -> void:
	# Enable input processing
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Initialize arrays
	runes = [rune1, rune2, rune3]
	slots = [slot1, slot2, slot3]
	
	# Store original positions
	for i in range(3):
		original_rune_positions.append(runes[i].global_position)
		# Enable mouse input for runes
		runes[i].mouse_filter = Control.MOUSE_FILTER_STOP
		# Connect gui_input signal for each rune
		runes[i].gui_input.connect(_on_rune_gui_input.bind(i))
	
	# Setup slots to accept drops
	for i in range(3):
		slots[i].mouse_filter = Control.MOUSE_FILTER_STOP
		slots[i].gui_input.connect(_on_slot_gui_input.bind(i))
	
	# Generate random correct mapping
	_generate_random_mapping()
	
	# Reset game state
	reset_game()


func _generate_random_mapping() -> void:
	# Create an array of slot indices [0, 1, 2]
	var available_slots = [0, 1, 2]
	
	# Shuffle the array to assign random slots to runes
	available_slots.shuffle()
	
	# Assign each rune to a shuffled slot
	for rune_idx in range(3):
		correct_mapping.append(available_slots[rune_idx])
	
	print("Correct mapping: Rune 0 -> Slot ", correct_mapping[0], ", Rune 1 -> Slot ", correct_mapping[1], ", Rune 2 -> Slot ", correct_mapping[2])


func reset_game() -> void:
	# Reset game state
	game_won = false
	placed_runes.clear()
	
	# Return all runes to original positions
	for i in range(3):
		var rune = runes[i]
		# Make sure rune is in the right parent
		if rune.get_parent() != $ColorRect2/VBoxContainer2:
			$ColorRect2/VBoxContainer2.add_child(rune)
			
		rune.global_position = original_rune_positions[i]
		rune.visible = true
		rune.mouse_filter = Control.MOUSE_FILTER_STOP
		
	# Clear slots
	for i in range(3):
		slots[i].self_modulate = Color(1, 1, 1, 1)  # Reset color
	
	# Generate new random mapping
	correct_mapping.clear()
	_generate_random_mapping()


func _on_rune_gui_input(event: InputEvent, rune_idx: int) -> void:
	var rune = runes[rune_idx]
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Start drag
			dragged_rune = rune
			dragged_rune_index = rune_idx
			drag_offset = rune.global_position - get_global_mouse_position()
			
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
		reset_game()
	
	dragged_rune = null
	dragged_rune_index = -1


func _on_game_won() -> void:
	print("Game won!")
	game_won_signal.emit()


func _process(delta: float) -> void:
	# If we're dragging a rune, move it with the mouse
	if dragged_rune != null:
		dragged_rune.global_position = get_global_mouse_position() + drag_offset


func _unhandled_input(event: InputEvent) -> void:
	# Close the minigame when ESC is pressed
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		queue_free()


# Public function to reset the game
func reset() -> void:
	reset_game()
