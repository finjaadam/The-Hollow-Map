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
	print("Key aufgehoben")
	team_keys += 1
	keys_changed.emit(team_keys)

func reset() -> void:
	team_keys = 0
	keys_changed.emit(team_keys)
