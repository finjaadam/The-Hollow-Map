extends Node

var team_keys := 0
var team_lives: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal keys_changed(new_amount)

#signal lives_changed(new_amount)

func collect_key() -> void:
	# is checked here because if a player leaves the game, it is still possible to open the door!
	var player_count = get_tree().get_nodes_in_group("player").size()
	if player_count > team_keys:
		team_keys += 1
		keys_changed.emit(team_keys)

func reset() -> void:
	team_keys = 0
	keys_changed.emit(team_keys)
