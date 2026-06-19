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

# Replicated over the network instead of `position` directly, so remote
# peers can smoothly interpolate towards it rather than snapping on every
# packet (which caused visible micro-jumps when packets arrive unevenly).
var network_position: Vector3 = Vector3.ZERO
@export var network_interpolation_speed: float = 20.0
var network_rotation: Vector3 = Vector3.ZERO

func _ready() -> void:
	_on_ready()
	network_position = position
	network_rotation = rotation
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
	
	# Connect to GameManager game end signals
	GameManager.players_won.connect(_on_players_won)
	GameManager.monster_won.connect(_on_monster_won)

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
		network_rotation = rotation
		
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
	_handle_animations(direction)
	network_position = position

	var is_actually_moving = Vector2(velocity.x, velocity.z).length() > 0.1
	footstep_controller.tick(is_on_floor(), is_actually_moving, delta)

func _process(delta: float) -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	if is_multiplayer_authority():
		return
	position = position.lerp(network_position, clamp(delta * network_interpolation_speed, 0.0, 1.0))
	rotation = rotation.lerp(network_rotation, clamp(delta * network_interpolation_speed, 0.0, 1.0))

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

# --- Game End Handlers ---

func _on_players_won():
	SceneLoader.goto_scene("res://ui/screens/game_end/PlayerWinScreen.tscn")

func _on_monster_won():
	SceneLoader.goto_scene("res://ui/screens/game_end/MonsterWinScreen.tscn")

func _handle_animations(_direction: Vector3) -> void:
	pass
