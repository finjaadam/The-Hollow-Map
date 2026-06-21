extends Node3D

@export var catch_duration: float = 5.0
@export var diffuse_hold_time: float = 2.0

@onready var catch_area: Area3D = $CatchArea
@onready var diffuse_area: Area3D = $DiffuseArea

var _diffusing_player: General_Player = null
var _diffuse_progress: float = 0.0

func _ready() -> void:
	catch_area.body_entered.connect(_on_catch_body_entered)
	diffuse_area.body_entered.connect(_on_diffuse_body_entered)
	diffuse_area.body_exited.connect(_on_diffuse_body_exited)

func _process(delta: float) -> void:
	if not _diffusing_player or SceneLoader.is_paused:
		return
	if _diffusing_player.is_movement_locked:
		return

	if Input.is_action_pressed("interact"):
		_diffuse_progress += delta
		if _diffuse_progress >= diffuse_hold_time:
			_remove_trap_for_all.rpc()
	else:
		_diffuse_progress = 0.0

func _on_catch_body_entered(body: Node3D) -> void:
	if not (body is General_Player) or body.ownRole != General_Player.Role.PLAYER:
		return
	if body.is_movement_locked:
		return

	body.is_movement_locked = true

	if body.is_multiplayer_authority():
		var overlay := body.canvas as InGameUIOverlay
		overlay.show_message("Du kannst dich für %d Sekunden nicht bewegen!" % int(catch_duration), catch_duration)

	await get_tree().create_timer(catch_duration).timeout
	if is_instance_valid(body):
		body.is_movement_locked = false

func _on_diffuse_body_entered(body: Node3D) -> void:
	if body is General_Player and body.is_multiplayer_authority() and body.ownRole == General_Player.Role.PLAYER:
		_diffusing_player = body
		_diffuse_progress = 0.0

func _on_diffuse_body_exited(body: Node3D) -> void:
	if body == _diffusing_player:
		_diffusing_player = null
		_diffuse_progress = 0.0

@rpc("any_peer", "call_local", "reliable")
func _remove_trap_for_all() -> void:
	queue_free()
