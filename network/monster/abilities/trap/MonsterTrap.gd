extends Node3D

@export var catch_duration: float = 5.0
@export var diffuse_hold_time: float = 2.0

@onready var catch_area: Area3D = $CatchArea
@onready var diffuse_area: Area3D = $DiffuseArea
@onready var diffuse_prompt: InteractionPrompt = $DiffusePrompt
@onready var trap_sound: RaytracedAudioPlayer3D = $TrapSound

var _diffusing_player: General_Player = null
var _diffuse_progress: float = 0.0
var _idle_prompt_text: String

func _ready() -> void:
	catch_area.body_entered.connect(_on_catch_body_entered)
	diffuse_area.body_entered.connect(_on_diffuse_body_entered)
	diffuse_area.body_exited.connect(_on_diffuse_body_exited)
	trap_sound.enabled.connect(BusManager.route_to_SFX_bus.bind(trap_sound))
	_idle_prompt_text = diffuse_prompt.text

func _process(delta: float) -> void:
	if not _diffusing_player or SceneLoader.is_paused:
		return
	if _diffusing_player.is_movement_locked:
		diffuse_prompt.hide_prompt()
		return

	if Input.is_action_pressed("interact"):
		_diffuse_progress += delta
		var remaining := diffuse_hold_time - _diffuse_progress
		if remaining <= 0.0:
			_diffusing_player = null
			diffuse_prompt.hide_prompt()
			_remove_trap_for_all.rpc()
			return
		diffuse_prompt.text = "Entschärfe... %.1fs" % remaining
		diffuse_prompt.show_prompt()
	else:
		_diffuse_progress = 0.0
		diffuse_prompt.text = _idle_prompt_text
		diffuse_prompt.show_prompt()

func _on_catch_body_entered(body: Node3D) -> void:
	if not (body is General_Player) or body.ownRole != General_Player.Role.PLAYER:
		return
	if body.is_movement_locked:
		return

	body.is_movement_locked = true
	_spring_trap()

	if body.is_multiplayer_authority():
		_play_trap_sound.rpc()
		var overlay := body.canvas as InGameUIOverlay
		overlay.show_countdown("Du bist in eine Falle getreten!", catch_duration)

	# Don't queue_free() until after this await finishes - freeing `self`
	# while this coroutine is suspended on it would break the resume.
	await get_tree().create_timer(catch_duration).timeout
	if is_instance_valid(body):
		body.is_movement_locked = false

	queue_free()

## Consumes the trap once it has caught someone: hides it and stops it from
## triggering or being diffused again. Each client detects the catch
## independently (the area overlap is evaluated locally against the
## replicated player position), so no RPC is needed here.
func _spring_trap() -> void:
	visible = false
	catch_area.monitoring = false
	diffuse_area.monitoring = false
	_diffusing_player = null
	diffuse_prompt.hide_prompt()

func _on_diffuse_body_entered(body: Node3D) -> void:
	if body is General_Player and body.is_multiplayer_authority() and body.ownRole == General_Player.Role.PLAYER:
		_diffusing_player = body
		_diffuse_progress = 0.0

func _on_diffuse_body_exited(body: Node3D) -> void:
	if body == _diffusing_player:
		_diffusing_player = null
		_diffuse_progress = 0.0
		diffuse_prompt.text = _idle_prompt_text
		diffuse_prompt.hide_prompt()

@rpc("any_peer", "call_local", "reliable")
func _remove_trap_for_all() -> void:
	queue_free()

@rpc("any_peer", "call_local", "unreliable")
func _play_trap_sound() -> void:
	trap_sound.play()
