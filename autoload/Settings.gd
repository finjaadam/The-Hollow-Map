extends Node

signal setting_changed(setting_name: String, value)

var settings_data = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 0.8,
	"ui_volume": 0.6,
	"fullscreen": true,
	"vsync": true,
	"resolution": {"x": 1920, "y": 1080},  # Store as dict for JSON compatibility
	"language": "en",
	"show_loading_screen": true,
	"controls": {}
}

var settings_file_path: String

func _ready():
	var project_name: String = ProjectSettings.get_setting("application/config/name", "Game")
	var safe_name: String = project_name.to_lower().replace(" ", "_").replace("-", "_")
	safe_name = safe_name.strip_edges().replace("/", "_").replace("\\", "_")
	settings_file_path = "user://%s_settings.save" % safe_name

	_ensure_default_input_actions()
	load_settings()
	apply_settings()

func load_settings():
	if not FileAccess.file_exists(settings_file_path):
		save_settings()
		return
	var file = FileAccess.open(settings_file_path, FileAccess.READ)
	if file == null:
		print("Error loading settings file"); return
	var json_string: String = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Error parsing settings JSON"); return
	var loaded_data = json.data
	for key in loaded_data:
		if key in settings_data:
			settings_data[key] = loaded_data[key]

func save_settings():
	var file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	if file == null:
		print("Error creating settings file"); return
	var json_string: String = JSON.stringify(settings_data)
	file.store_string(json_string)
	file.close()

func get_setting(key: String, default_value = null):
	return settings_data.get(key, default_value)

func set_setting(key: String, value):
	if key in settings_data and settings_data[key] != value:
		settings_data[key] = value
		setting_changed.emit(key, value)
		save_settings()

func get_resolution_vector() -> Vector2i:
	var res_data = get_setting("resolution", {"x": 1920, "y": 1080})
	if res_data is Dictionary:
		return Vector2i(res_data.get("x", 1920), res_data.get("y", 1080))
	elif res_data is Vector2i:
		return res_data
	elif res_data is Vector2:
		return Vector2i(int(res_data.x), int(res_data.y))
	else:
		# Fallback for any unexpected format
		return Vector2i(1920, 1080)

func set_resolution(width: int, height: int):
	set_setting("resolution", {"x": width, "y": height})

func _set_bus(bus_name: String, vol: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	if idx < 0:
		idx = AudioServer.get_bus_index("Master")
	if idx >= 0:
		var v = clamp(vol, 0.0001, 1.0) # avoid -inf dB
		AudioServer.set_bus_volume_db(idx, linear_to_db(v))

func apply_settings():
	_set_bus("Master", get_setting("master_volume"))
	_set_bus("Music", get_setting("music_volume"))
	_set_bus("SFX", get_setting("sfx_volume"))
	_set_bus("UI", get_setting("ui_volume"))

	if get_setting("fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var res: Vector2i = get_resolution_vector()
		DisplayServer.window_set_size(res)

	if get_setting("vsync"):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	var language: String = str(get_setting("language", "en"))
	TranslationServer.set_locale(language)

func _ensure_default_input_actions():
	# Use KEY_* constants (Godot 4)
	var defaults = {
		"ui_accept": [KEY_ENTER, KEY_SPACE],
		"ui_cancel": [KEY_ESCAPE],
		"ui_left": [KEY_LEFT],
		"ui_right": [KEY_RIGHT],
		"ui_up": [KEY_UP],
		"ui_down": [KEY_DOWN],
		"pause": [KEY_ESCAPE, KEY_P],
		"fire": [KEY_Z],
		"bomb": [KEY_X],
		"dash": [KEY_C],
	}

	for action in defaults.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var existing = InputMap.action_get_events(action)
		for keycode in defaults[action]:
			var already = false
			for e in existing:
				if e is InputEventKey and e.keycode == keycode:
					already = true
					break
			if not already:
				var ev = InputEventKey.new()
				ev.keycode = keycode
				InputMap.action_add_event(action, ev)

	var joy_defaults = {
		"ui_accept": [JOY_BUTTON_A],
		"ui_cancel": [JOY_BUTTON_B],
		"fire": [JOY_BUTTON_X],
		"bomb": [JOY_BUTTON_Y],
		"pause": [JOY_BUTTON_START],
	}

	for action in joy_defaults.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for jb in joy_defaults[action]:
			var has = false
			for e in InputMap.action_get_events(action):
				if e is InputEventJoypadButton and e.button_index == jb:
					has = true
					break
			if not has:
				var je = InputEventJoypadButton.new()
				je.button_index = jb
				InputMap.action_add_event(action, je)

func reset_to_defaults():
	settings_data = {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 0.8,
		"ui_volume": 0.6,
		"fullscreen": true,
		"vsync": true,
		"resolution": {"x": 1920, "y": 1080},
		"language": "en",
		"show_loading_screen": true,
		"controls": {}
	}
	save_settings()
	apply_settings()

func should_show_loading_screen() -> bool:
	return get_setting("show_loading_screen", true)
