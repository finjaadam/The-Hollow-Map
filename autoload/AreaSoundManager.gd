extends Node

enum SurfaceType { STONE, GRAVEL, WATER, WOOD, SAND }

const FOOTSTEP_LIBRARY: AudioLibrary = preload("res://audio/soundfx/map-areas/footstep_sounds.tres")

static func surface_name(surface: SurfaceType) -> String:
	return SurfaceType.keys()[surface].to_lower()

func get_footstep(surface: SurfaceType) -> AudioStream:
	var key := surface_name(surface)
	var streams: Array = FOOTSTEP_LIBRARY.footstep_surfaces.get(key, [])
	if streams == null or streams.is_empty():
		streams = FOOTSTEP_LIBRARY.footstep_surfaces.values()[0]
	return streams[randi() % streams.size()]
