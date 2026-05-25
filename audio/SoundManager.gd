extends Node

enum SurfaceType { STONE, GRAVEL, WATER, WOOD, SAND }

var _footstep_sounds: Dictionary = {}
var _fallback: Array[AudioStream] = []
const AUDIO_DIR: String = "res://audio/soundfx/map-region/"

func _ready() -> void:
	_load_footstep_sounds()

func _load_footstep_sounds() -> void:
	var dir = DirAccess.open(AUDIO_DIR)
	if not dir:
		print("SoundManager: Directory not found: ", AUDIO_DIR)
		return

	for surface_dir in dir.get_directories():
		var surface_path = AUDIO_DIR + surface_dir + "/"
		var surface_dir_access = DirAccess.open(surface_path)
		if not surface_dir_access:
			continue
		var streams: Array[AudioStream] = []
		for file in surface_dir_access.get_files():
			if not file.get_extension().to_lower() == "mp3":
				continue
			var stream = load(surface_path + file)
			if stream:
				streams.append(stream)
		if not streams.is_empty():
			_footstep_sounds[surface_dir] = streams

	if not _footstep_sounds.is_empty():
		_fallback = _footstep_sounds.values()[0]

static func surface_name(surface: SurfaceType) -> String:
	return SurfaceType.keys()[surface].to_lower()

func get_footstep(surface: SurfaceType) -> AudioStream:
	var key = surface_name(surface)
	var streams = _footstep_sounds.get(key)
	if streams == null or streams.is_empty():
		streams = _fallback
	if streams == null or streams.is_empty():
		return null
	return streams[randi() % streams.size()]
