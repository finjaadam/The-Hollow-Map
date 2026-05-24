extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		$Camera3D.current = true
	else:
		$Camera3D.current = false

func _input(event):
	# Only process input for the local player
	if not is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$Camera3D.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	if !is_multiplayer_authority():
		return

	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		# Transform direction relative to where the player is facing
		direction = transform.basis * direction
		direction.y = 0  # Keep movement horizontal (ignore camera tilt)
		direction = direction.normalized()

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	velocity = target_velocity
	move_and_slide()

func _unhandled_input(event):
	# CR5: Pause menu implementation in game scene
	if event.is_action_pressed("pause"):
		var paused: bool = not get_tree().paused
		get_tree().paused = paused
		if paused and ResourceLoader.exists("res://ui/screens/menu/PauseMenu.tscn"):
			var pause_menu: Node = load("res://ui/screens/menu/PauseMenu.tscn").instantiate()
			get_tree().root.add_child(pause_menu)
