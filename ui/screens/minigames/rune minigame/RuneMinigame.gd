extends Control

# Rune minigame script
# Features:
# - 3 runes on the right, 9 slots in a 3x3 grid on the left
# - Only 3 of the 9 slots are correct (show ghost runes)
# - Runes are draggable
# - Each rune has a randomly assigned correct slot
# - Wrong placement resets all runes
# - All correct placements = win

# Signal to inform the main game when the minigame is finished
signal game_finished(success: bool)

# Sound for mistakes
const ERROR_SOUND = preload("res://network/monster/abilities/trap/trap_sound.mp3")
var error_sound_player: AudioStreamPlayer

@onready var statusLabel = $Background/StatusLabel
@onready var resetTimer = $ResetTimer

# Node references
@onready var rune1 = $Background/MainHBox/VBoxContainer2/Rune1
@onready var rune2 = $Background/MainHBox/VBoxContainer2/Rune2
@onready var rune3 = $Background/MainHBox/VBoxContainer2/Rune3

@onready var slot1 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot1
@onready var slot2 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot2
@onready var slot3 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot3
@onready var slot4 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot4
@onready var slot5 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot5
@onready var slot6 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot6
@onready var slot7 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot7
@onready var slot8 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot8
@onready var slot9 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot9

# Ghost rune references (faint images in slots)
@onready var ghost_rune1 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot1/GhostRune1
@onready var ghost_rune2 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot2/GhostRune2
@onready var ghost_rune3 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot3/GhostRune3
@onready var ghost_rune4 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot4/GhostRune4
@onready var ghost_rune5 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot5/GhostRune5
@onready var ghost_rune6 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot6/GhostRune6
@onready var ghost_rune7 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot7/GhostRune7
@onready var ghost_rune8 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot8/GhostRune8
@onready var ghost_rune9 = $Background/MainHBox/VBoxContainer3/SlotsGrid/Slot9/GhostRune9

# Array of ghost runes for easier management
var ghost_runes = []

# Game state
var runes = []
var slots = []
var game_active = false

# Total number of slots (9) and correct slots (3)
const TOTAL_SLOTS = 9
const CORRECT_SLOTS = 3

# Array of slot indices that are correct (3 out of 9)
var correct_slot_indices = []

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
	slots = [slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8, slot9]
	ghost_runes = [ghost_rune1, ghost_rune2, ghost_rune3, ghost_rune4, ghost_rune5, ghost_rune6, ghost_rune7, ghost_rune8, ghost_rune9]
	
	# Enable mouse input for runes
	for i in range(3):
		runes[i].mouse_filter = Control.MOUSE_FILTER_STOP
		# Connect gui_input signal for each rune
		runes[i].gui_input.connect(_on_rune_gui_input.bind(i))
	
	# Setup slots to accept drops
	for i in range(TOTAL_SLOTS):
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
	# Select 3 random slots out of 9 to be the correct ones
	correct_slot_indices.clear()
	
	# Create an array of all slot indices [0, 1, 2, 3, 4, 5, 6, 7, 8]
	var all_slots = []
	for i in range(TOTAL_SLOTS):
		all_slots.append(i)
	
	# Shuffle and pick the first 3
	all_slots.shuffle()
	for i in range(CORRECT_SLOTS):
		correct_slot_indices.append(all_slots[i])
	
	# Sort for consistency (optional, but makes debugging easier)
	correct_slot_indices.sort()
	
	# Assign each rune to one of the correct slots
	# We want each rune to go to a different correct slot
	var correct_slots_shuffled = correct_slot_indices.duplicate()
	correct_slots_shuffled.shuffle()
	
	correct_mapping.clear()
	for rune_idx in range(3):
		correct_mapping.append(correct_slots_shuffled[rune_idx])
	
	print("Correct slots: ", correct_slot_indices)
	print("Correct mapping: Rune 0 -> Slot ", correct_mapping[0], ", Rune 1 -> Slot ", correct_mapping[1], ", Rune 2 -> Slot ", correct_mapping[2])


func _on_pause_toggled(is_paused: bool) -> void:
	if not is_paused and game_active:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _update_ghost_runes() -> void:
	# Hide all ghost runes initially
	for i in range(TOTAL_SLOTS):
		ghost_runes[i].visible = false
		ghost_runes[i].texture = null
	
	# Update ghost rune textures based on correct mapping
	# Each ghost rune in a correct slot should show the texture of the rune that belongs there
	for rune_idx in range(3):
		var correct_slot_idx = correct_mapping[rune_idx]
		if correct_slot_idx != null:
			# Set the ghost rune texture to match the rune that belongs here
			ghost_runes[correct_slot_idx].texture = runes[rune_idx].texture
			ghost_runes[correct_slot_idx].visible = true


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
	for i in range(TOTAL_SLOTS):
		slots[i].self_modulate = Color(1, 1, 1, 1)  # Reset color
		# Reset StyleBox background color
		var style = slots[i].get_theme_stylebox("panel").duplicate()
		style.bg_color = Color(0.25, 0.25, 0.25, 1)
		slots[i].add_theme_stylebox_override("panel", style)
	
	# Generate new random mapping
	correct_mapping.clear()
	_generate_random_mapping()
	
	# Update ghost runes with new mapping
	_update_ghost_runes()


func _on_rune_gui_input(event: InputEvent, rune_idx: int) -> void:
	var rune = runes[rune_idx]
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Start drag
			dragged_rune = rune
			dragged_rune_index = rune_idx
			drag_offset = rune.global_position - get_global_mouse_position()
			
			# Hide ghost runes on first grab
			for i in range(TOTAL_SLOTS):
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
				
				for i in range(TOTAL_SLOTS):
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
		# Move the rune to the slot's position
		var rune = runes[rune_idx]
		rune.global_position = slots[slot_idx].global_position
		
		# Mark as placed
		placed_runes[rune_idx] = slot_idx
		
		# Change slot color to indicate correct placement
		var style = slots[slot_idx].get_theme_stylebox("panel").duplicate()
		style.bg_color = Color(0, 1, 0, 1)  # Green
		slots[slot_idx].add_theme_stylebox_override("panel", style)
		
		# Disable dragging for placed rune
		rune.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Check if all runes are placed correctly
		if placed_runes.size() == 3:
			game_won = true
			_on_game_won()
			
	else:
		# Play error sound
		error_sound_player.stream = ERROR_SOUND
		error_sound_player.play()
		statusLabel.text = "Falsch platziert! Das Monster hat dich gehört..."
		resetTimer.start()
	
	dragged_rune = null
	dragged_rune_index = -1


func _on_game_won() -> void:
	print("Game won!")
	game_active = false
	game_finished.emit(true)
	# Give control back
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	queue_free()


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


func _on_reset_timer_timeout() -> void:
	statusLabel.text = ""
	reset_game()
