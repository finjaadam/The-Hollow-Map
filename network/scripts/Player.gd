extends General_Player

@export var flashlight: SpotLight3D

var is_fishing := false

var flashlight_active := false
var flashlight_on_cooldown := false
var flashlight_cooldown_remaining: float = 0.0

const FLASHLIGHT_DURATION := 3.0
const FLASHLIGHT_COOLDOWN := 30.0

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

func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("FLASHLIGHT") and flashlight:
		if not flashlight_active and not flashlight_on_cooldown:
			_activate_flashlight()

func _on_physics_process(delta: float) -> void:
	if flashlight_on_cooldown:
		flashlight_cooldown_remaining = max(0.0, flashlight_cooldown_remaining - delta)
		canvas.set_flashlight_cooldown(flashlight_cooldown_remaining, FLASHLIGHT_COOLDOWN)

func _activate_flashlight() -> void:
	flashlight_active = true
	flashlight.visible = true
	var timer := get_tree().create_timer(FLASHLIGHT_DURATION)
	timer.timeout.connect(_deactivate_flashlight)

func _deactivate_flashlight() -> void:
	flashlight_active = false
	flashlight.visible = false
	flashlight_on_cooldown = true
	flashlight_cooldown_remaining = FLASHLIGHT_COOLDOWN
	canvas.set_flashlight_cooldown(FLASHLIGHT_COOLDOWN, FLASHLIGHT_COOLDOWN)
	var timer := get_tree().create_timer(FLASHLIGHT_COOLDOWN)
	timer.timeout.connect(_on_flashlight_cooldown_end)

func _on_flashlight_cooldown_end() -> void:
	flashlight_on_cooldown = false
	canvas.set_flashlight_cooldown(0.0, FLASHLIGHT_COOLDOWN)
