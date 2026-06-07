extends Node3D

var all_players: Array

@onready var area: Area3D = $Area3D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") && check_if_exit_should_open():
		open_exit()

func check_if_exit_should_open() -> bool:
	all_players = get_tree().get_nodes_in_group("player")
	
	var players_in_area = []
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			players_in_area.append(body)
	
	if players_in_area.size() == all_players.size() && TeamProperties.team_keys == all_players.size():
		return true
	
	return false

func open_exit() -> void:
	print("exit geöffnet")
	# load game-end scene
