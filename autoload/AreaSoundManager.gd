extends Node

enum SurfaceType { STONE, GRAVEL, WATER, WOOD, SAND }

const FOOTSTEP_LIBRARY: AudioLibrary = preload("res://audio/soundfx/map-areas/footstep_sounds.tres")

var _default_player: RaytracedAudioPlayer3D

func _ready():
	_default_player = RaytracedAudioPlayer3D.new()
	_default_player.name = "DefaultAmbientPlayer"
	_default_player.stream = preload("res://audio/music/ambient/Stone.mp3")
	_default_player.volume_db = -20.0
	_default_player.unit_size = 1000.0
	_default_player.max_distance = 0.0
	_default_player.bus = &"Master"
	_default_player.attenuation_model = RaytracedAudioPlayer3D.ATTENUATION_DISABLED
	_default_player.autoplay = true
	add_child(_default_player)


func enter_zone():
	var tween := create_tween()
	tween.tween_property(_default_player, "volume_db", -80.0, 3.0).set_ease(Tween.EASE_IN_OUT)


func exit_zone():
	var tween := create_tween()
	tween.tween_property(_default_player, "volume_db", -20.0, 3.0).set_ease(Tween.EASE_IN_OUT)


static func surface_name(surface: SurfaceType) -> String:
	return SurfaceType.keys()[surface].to_lower()

func get_footstep(surface: SurfaceType) -> AudioStream:
	var key := surface_name(surface)
	var streams: Array = FOOTSTEP_LIBRARY.footstep_surfaces.get(key, [])
	if streams == null or streams.is_empty():
		streams = FOOTSTEP_LIBRARY.footstep_surfaces.values()[0]
	return streams[randi() % streams.size()]
