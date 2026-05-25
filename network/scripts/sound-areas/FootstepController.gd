extends Node3D

@export var footstep_interval: float = 0.5
@export var detector_radius: float = 0.6
@export var detector_offset: Vector3 = Vector3(0, -0.3, 0)

var current_surface: SoundManager.SurfaceType = SoundManager.SurfaceType.STONE
var _footstep_cooldown: float = 0.0
var _overlapping_regions: Array[Area3D] = []
var _audio: AudioStreamPlayer3D

func _ready():
	var detector = Area3D.new()
	detector.name = "FootstepDetector"
	detector.area_entered.connect(_on_footstep_area_entered)
	detector.area_exited.connect(_on_footstep_area_exited)
	var shape = SphereShape3D.new()
	shape.radius = detector_radius
	var collision = CollisionShape3D.new()
	collision.shape = shape
	collision.position = detector_offset
	detector.add_child(collision)
	add_child(detector)

	_audio = AudioStreamPlayer3D.new()
	_audio.name = "FootstepAudio"
	_audio.bus = &"SFX"
	add_child(_audio)

func _on_footstep_area_entered(area: Area3D):
	if area.is_in_group("footstep_region"):
		_overlapping_regions.append(area)
		current_surface = area.surface_type
		print("entered ", area.name)

func _on_footstep_area_exited(area: Area3D):
	_overlapping_regions.erase(area)
	print("exited ", area.name)
	if _overlapping_regions:
		current_surface = _overlapping_regions[-1].surface_type
		print("surface: ", area.name)
	else:
		current_surface = SoundManager.SurfaceType.STONE
		print("surface: STONE (default)")

func tick(on_floor: bool, is_moving: bool, delta: float):
	if not on_floor or not is_moving:
		_footstep_cooldown = 0.0
		return
	_footstep_cooldown -= delta
	if _footstep_cooldown <= 0:
		_play_footstep()

func _play_footstep():
	var stream = SoundManager.get_footstep(current_surface)
	if stream:
		_audio.stream = stream
		_audio.play()
	_footstep_cooldown = footstep_interval
