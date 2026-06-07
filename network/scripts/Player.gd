extends CharacterBody3D

@export var mouse_sensitivity = 0.003
# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

@export var debug_env: Environment
@export var player_env: Environment

var target_velocity = Vector3.ZERO

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_multiplayer_authority():
		$Camera3D.current = true
		$Camera3D.environment = player_env
	else:
		$Camera3D.current = false
	SceneLoader.paused.connect(_on_pause)

func _input(event):
	# Only process input for the local player
	if not is_multiplayer_authority():
		return
	if SceneLoader.is_paused:
		return
	
	if OS.is_debug_build():
		if event.is_action_pressed("DEBUG_TELEPORT"):
			teleport(Vector3(0, 2, -120))
			$Camera3D.environment = debug_env
		if event.is_action_pressed("MAP_TELEPORT"):
			teleport(Vector3(-33, 2, 41))
			$Camera3D.environment = player_env
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	if not multiplayer.has_multiplayer_peer():
		return
	if not is_multiplayer_authority():
		return
	if SceneLoader.is_paused:
		return

	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):  	direction.x += 1
	if Input.is_action_pressed("move_left"):   	direction.x -= 1
	if Input.is_action_pressed("move_back"):   	direction.z += 1
	if Input.is_action_pressed("move_forward"):	direction.z -= 1

	if direction != Vector3.ZERO:
		direction = transform.basis * direction
		direction.y = 0
		direction = direction.normalized()

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if is_on_floor():
		target_velocity.y = -0.5
	else:
		target_velocity.y -= fall_acceleration * delta
	
	velocity = target_velocity
	move_and_slide()

	$FootstepController.tick(is_on_floor(), direction != Vector3.ZERO, delta)

func _unhandled_input(event):
	if not is_multiplayer_authority():
		return
	# CR5: Pause menu implementation in game scene
	if event.is_action_pressed("pause"):
		SceneLoader.toggle_pause()

func teleport(position: Vector3):
	global_position = position

func change_env(environment: Environment):
	get_node("Camera3D").environment = environment

func _on_pause(is_paused: bool):
	if not is_multiplayer_authority():
		return
	if is_paused:
		var pause_menu: Node = load("res://ui/screens/menu/pause/PauseMenu.tscn").instantiate()
		get_tree().current_scene.add_child(pause_menu)
		SceneLoader.scene_loading_finished
