extends Node3D

@export var footstep_interval: float = 0.5		# Minimum time between footstep sounds in seconds
@export var detector_radius: float = 0.6			# Radius of the footstep detection sphere
@export var detector_offset: Vector3 = Vector3(0, -0.3, 0)	# Offset from player origin for ground detection

var current_surface: AreaSoundManager.SurfaceType = AreaSoundManager.SurfaceType.STONE
var _footstep_cooldown: float = 0.0		# Timer for enforcing footstep_interval
var _overlapping_regions: Array[Area3D] = []	# All footstep regions currently overlapping the detector
var _audio: AudioStreamPlayer3D

func _ready():
	# Create a spherical detector to sense footstep regions beneath the player
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

	# Audio player for playing surface-specific footstep sounds
	_audio = RaytracedAudioPlayer3D.new()
	_audio.name = "FootstepAudio"
	add_child(_audio)

func _on_footstep_area_entered(area: Area3D):
	# Track overlapping regions and switch to the new surface
	if area.is_in_group("footstep_region"):
		_overlapping_regions.append(area)
		current_surface = area.surface_type
		print("entered ", area.name)

func _on_footstep_area_exited(area: Area3D):
	# Fall back to the last overlapping region, or default surface if none remain
	_overlapping_regions.erase(area)
	print("exited ", area.name)
	if _overlapping_regions:
		current_surface = _overlapping_regions[-1].surface_type
		print("surface: ", area.name)
	else:
		current_surface = AreaSoundManager.SurfaceType.STONE
		print("surface: STONE (default)")

func tick(on_floor: bool, is_moving: bool, delta: float):
	# Plays footsteps at interval when walking on ground
	if not on_floor or not is_moving:
		_footstep_cooldown = 0.0
		return
	_footstep_cooldown -= delta
	if _footstep_cooldown <= 0:
		_play_footstep.rpc(current_surface)

@rpc("any_peer", "call_local", "unreliable")
func _play_footstep(surface: AreaSoundManager.SurfaceType):
	var stream = AreaSoundManager.get_footstep(surface)
	if stream:
		_audio.stream = stream
		_audio.play()
	_footstep_cooldown = footstep_interval
