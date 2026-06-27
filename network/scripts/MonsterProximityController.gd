extends Node

@export var player: General_Player

@export var alert_range: float = 15.0
@export var jump_scare_range: float = 5.0
@export var fade_out_delay: float = 5.0
@export var roar_interval_min: float = 3.0
@export var roar_interval_max: float = 10.0

@export_group("Audio Streams")
@export var jump_scare_stream: AudioStream
@export var heartbeat_stream: AudioStream
@export var chase_music_stream: AudioStream
@export var monster_roar_streams: Array[AudioStream]

@export_group("Volume (dB)")
@export var jump_scare_volume: float = -30.0
@export var heartbeat_volume: float = 0.0
@export var chase_music_volume: float = -40.0
@export var roar_volume: float = -30.0

var _jump_scare_player: RaytracedAudioPlayer3D
var _heartbeat_player: RaytracedAudioPlayer3D
var _chase_music_player: RaytracedAudioPlayer3D
var _roar_player: RaytracedAudioPlayer3D

var _monster_was_in_alert := false
var _monster_in_alert := false
var _jumpscare_triggered := false
var _fade_out_timer: float = 0.0
var _roar_cooldown: float = 0.0


func _ready() -> void:
	if player == null:
		push_warning("MonsterProximityAudio: player is not assigned")
		return

	_jump_scare_player = RaytracedAudioPlayer3D.new()
	_heartbeat_player = RaytracedAudioPlayer3D.new()
	_chase_music_player = RaytracedAudioPlayer3D.new()
	_roar_player = RaytracedAudioPlayer3D.new()

	var sfx = "SFX"
	_jump_scare_player.bus = sfx
	_heartbeat_player.bus = sfx
	_chase_music_player.bus = "Music"
	_roar_player.bus = sfx

	for p in [_jump_scare_player, _heartbeat_player, _chase_music_player, _roar_player]:
		add_child(p)

	_jump_scare_player.volume_db = jump_scare_volume
	_heartbeat_player.volume_db = heartbeat_volume
	_chase_music_player.volume_db = chase_music_volume

	_heartbeat_player.finished.connect(_on_heartbeat_finished)
	_chase_music_player.finished.connect(_on_chase_music_finished)

	_reset_roar_cooldown()


func _process(delta: float) -> void:
	if player == null or not player.is_multiplayer_authority():
		return

	var monster := _get_monster_in_range(alert_range)
	_monster_in_alert = monster != null

	if _monster_in_alert and not _monster_was_in_alert:
		_on_monster_entered_alert()
	elif not _monster_in_alert and _monster_was_in_alert:
		_on_monster_exited_alert()

	if _monster_in_alert:
		_fade_out_timer = 0.0

		var dist = player.global_position.distance_to(monster.global_position)
		if dist <= jump_scare_range and not _jumpscare_triggered and _has_line_of_sight(monster):
			_play_audio(_jump_scare_player, jump_scare_stream)
			_jumpscare_triggered = true

		_roar_cooldown -= delta
		if _roar_cooldown <= 0.0 and not monster_roar_streams.is_empty():
			_play_random_roar()
			_reset_roar_cooldown()
	else:
		_fade_out_timer += delta
		if _fade_out_timer >= fade_out_delay:
			_stop_sounds()

	_monster_was_in_alert = _monster_in_alert


func _get_monster_in_range(range_val: float) -> Node3D:
	for monster in get_tree().get_nodes_in_group("monster"):
		if player.global_position.distance_to(monster.global_position) <= range_val:
			return monster
	return null


func _has_line_of_sight(monster: Node3D) -> bool:
	var camera := player.camera3d
	if camera == null:
		return false
	var to_monster := (monster.global_position - camera.global_position).normalized()
	var camera_forward := -camera.global_transform.basis.z
	if camera_forward.dot(to_monster) < 0.5:
		return false
	var space := player.get_world_3d().direct_space_state
	if space == null:
		return false
	var query := PhysicsRayQueryParameters3D.create(camera.global_position, monster.global_position, 0x7FFFFFFF)
	query.exclude = [player.get_rid(), monster.get_rid()]
	return space.intersect_ray(query).is_empty()

func _on_monster_entered_alert() -> void:
	_jumpscare_triggered = false
	_play_audio(_heartbeat_player, heartbeat_stream)
	_play_audio(_chase_music_player, chase_music_stream)


func _on_monster_exited_alert() -> void:
	_fade_out_timer = 0.0


func _play_audio(player: RaytracedAudioPlayer3D, stream: AudioStream) -> void:
	if stream == null:
		return
	player.stream = stream
	if not player.playing:
		player.play()


func _stop_sounds() -> void:
	_heartbeat_player.stop()
	_chase_music_player.stop()
	_roar_player.stop()
	_monster_was_in_alert = false
	_monster_in_alert = false
	_jumpscare_triggered = true


func _reset_roar_cooldown() -> void:
	_roar_cooldown = randf_range(roar_interval_min, roar_interval_max)


func _play_random_roar() -> void:
	var stream = monster_roar_streams.pick_random()
	_roar_player.stream = stream
	_roar_player.volume_db = roar_volume
	_roar_player.play()


func _on_heartbeat_finished() -> void:
	if _monster_in_alert:
		_heartbeat_player.play()


func _on_chase_music_finished() -> void:
	if _monster_in_alert:
		_chase_music_player.play()
