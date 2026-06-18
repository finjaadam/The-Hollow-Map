class_name General_Player
extends CharacterBody3D

@export var mouse_sensitivity = 0.003
# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

@export var debug_env: Environment
@export var player_env: Environment

@export var footstep_controller: Node
@export var camera3d: Camera3D
@export var canvas: CanvasLayer

@export var animation_player: AnimationPlayer

var target_velocity = Vector3.ZERO
enum Role {PLAYER, MONSTER}
var ownRole: Role

func _ready() -> void:
	_on_ready()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Only create Camera + Environment for yourself
	if is_multiplayer_authority():
		camera3d.current = true
		camera3d.environment = player_env
		_setup_ui() # Only Render UI for yourself
	else:
		camera3d.current = false
		canvas.visible = false
	SceneLoader.paused.connect(_on_pause)

# Overwrite in Subclass
func _on_ready():
	pass

func _setup_ui():
	canvas.visible = true
	var roleLabel: Label = canvas.get_node("Role")
	roleLabel.text = "Spielende" if ownRole == Role.PLAYER else "Monster" 

func _input(event):
	# Only process input for the local player
	if not is_multiplayer_authority():
		return
	if SceneLoader.is_paused:
		return
	
	if OS.is_debug_build():
		if event.is_action_pressed("DEBUG_TELEPORT"):
			teleport(Vector3(0, 2, -120))
			camera3d.environment = debug_env
		if event.is_action_pressed("DEBUG_MAP_TELEPORT"):
			teleport(Vector3(-33, 2, 41))
			camera3d.environment = player_env
		if event.is_action_pressed("DEBUG_TOGGLE_ROLE"):
			_debug_toggle_role()
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera3d.rotate_x(-event.relative.y * mouse_sensitivity)
		camera3d.rotation.x = clamp(camera3d.rotation.x, deg_to_rad(-89), deg_to_rad(89))

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
	
	# Animations-Steuerung
	if animation_player: 
		if direction != Vector3.ZERO:
			if animation_player.current_animation != "Sneak_Walk/mixamo_com":
				animation_player.play("Sneak_Walk/mixamo_com")
		else:
			animation_player.stop()

	footstep_controller.tick(is_on_floor(), direction != Vector3.ZERO, delta)

func _unhandled_input(event):
	if not is_multiplayer_authority():
		return
	# CR5: Pause menu implementation in game scene
	if event.is_action_pressed("pause"):
		SceneLoader.toggle_pause()

func teleport(position: Vector3):
	global_position = position

func change_env(environment: Environment):
	camera3d.environment = environment

func _on_pause(is_paused: bool):
	if not is_multiplayer_authority():
		return
	if is_paused:
		var pause_menu: Node = load("res://ui/screens/menu/pause/PauseMenu.tscn").instantiate()
		get_tree().current_scene.add_child(pause_menu)
		SceneLoader.scene_loading_finished

func _debug_toggle_role() -> void:
	var new_role: String
	if ownRole == Role.PLAYER:
		ownRole = Role.MONSTER
		new_role = "monster"
	else:
		ownRole = Role.PLAYER
		new_role = "player"

	var my_id = multiplayer.get_unique_id()
	GameManager.player_roles[my_id] = new_role
	GameManager.set_starting_team_properties()
	
	# Tell the host/spawner to swap the scene for this peer
	NetworkManager._debug_respawn_peer.rpc_id(1, my_id, new_role)
