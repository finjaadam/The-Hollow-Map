extends Node

var team_keys: int
var team_lives: int

signal keys_changed(new_amount)
signal lives_changed(new_amount)

func collect_key() -> void:
	# is checked here because if a player leaves the game, it is still possible to open the door!
	var player_count = get_player_count()
	if player_count > team_keys:
		team_keys += 1
		keys_changed.emit(team_keys)
		
func remove_one_live() -> void:
	team_lives -= 1
	lives_changed.emit(team_lives)
	monster_wins_if_necessary()
		

func monster_wins_if_necessary() -> void:
	if team_lives <= 0:
		print("Monster hat gewonnen")
		#monster_win()
	return
		

func reset() -> void:
	team_keys = 0
	keys_changed.emit(team_keys)
	
	reset_team_lives()

func get_player_count() -> int:
	var player_count = 0
	var player_roles = NetworkManager.player_roles
	for player in player_roles:
		if player_roles[player] == "player":
			player_count += 1
	return player_count

func reset_team_lives() -> void:
	team_lives = get_player_count() * 50
	lives_changed.emit(team_lives)
