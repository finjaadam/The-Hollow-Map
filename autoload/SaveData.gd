extends Node

signal game_saved
signal game_loaded

var game_data = {
	"player_name": "",
	"games_started": 0,
	"games_finished": 0,
	"games_won_as_player": 0,
	"games_won_as_monster": 0,
	"games_lost_as_player": 0,
	"games_lost_as_monster": 0,
	"achievements": [],
	"last_played": ""
}

var save_file_path: String

func _ready():
	var project_name: String = ProjectSettings.get_setting("application/config/name", "Game")
	var safe_name: String = project_name.to_lower().replace(" ", "_").replace("-", "_")
	safe_name = safe_name.strip_edges().replace("/", "_").replace("\\", "_")
	save_file_path = "user://%s_savegame.save" % safe_name

func save_game():
	game_data["last_played"] = Time.get_datetime_string_from_system()
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file == null:
		print("Error creating save file"); return false
	var json_string: String = JSON.stringify(game_data)
	file.store_string(json_string)
	file.close()
	game_saved.emit()
	print("Game saved successfully")
	return true

func load_game():
	if not FileAccess.file_exists(save_file_path):
		print("No save file found"); return false
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file == null:
		print("Error loading save file"); return false
	var json_string: String = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Error parsing save JSON"); return false
	var loaded_data = json.data
	for key in loaded_data:
		if key in game_data:
			game_data[key] = loaded_data[key]
	game_loaded.emit()
	print("Game loaded successfully")
	return true

func has_save_file():
	return FileAccess.file_exists(save_file_path)

func delete_save():
	if FileAccess.file_exists(save_file_path):
		DirAccess.remove_absolute(save_file_path)
		print("Save file deleted")
		return true
	return false

func get_data(key: String, default_value = null):
	return game_data.get(key, default_value)

func set_data(key: String, value):
	if key in game_data:
		game_data[key] = value

func unlock_achievement(achievement_id: String):
	if achievement_id not in game_data["achievements"]:
		game_data["achievements"].append(achievement_id)

func has_achievement(achievement_id: String) -> bool:
	return achievement_id in game_data["achievements"]
