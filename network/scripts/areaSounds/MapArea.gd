extends Area3D

@export var surface_type: AreaSoundManager.SurfaceType = AreaSoundManager.SurfaceType.STONE
@export var ambient_streams: Array[AudioStream]
@export var ambient_volume_db: float = -10.0
@export var ambient_pitch_scale: float = 1.0
@export var ambient_unit_size: float = 10.0
@export var ambient_max_distance: float = 15.0
@export var ambient_position_offset: Vector3 = Vector3(0, 7, 0)

func _ready():
	add_to_group("footstep_region")

	for i in ambient_streams.size():
		var player = RaytracedAudioPlayer3D.new()
		player.name = "AmbientPlayer_%d" % i
		player.position = ambient_position_offset
		player.stream = ambient_streams[i]
		player.volume_db = ambient_volume_db
		player.pitch_scale = ambient_pitch_scale
		player.unit_size = ambient_unit_size
		player.max_distance = ambient_max_distance
		player.autoplay = true
		add_child(player)
