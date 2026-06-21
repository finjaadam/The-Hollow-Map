extends CanvasLayer

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_bar = $LiveBar

@onready var bw_keys = $bw_keys
@onready var colored_keys = $colored_keys

func _ready() -> void:
	GameManager.keys_changed.connect(_set_key_visibility)
	GameManager.state_updated.connect(_set_key_visibility)
	
	_set_key_visibility()
	
	live_bar.visible = !is_monster
	
	if is_monster: 
		return
	
	live_bar.max_value = GameManager.max_team_lives
	live_bar.value = GameManager.team_lives
	
	GameManager.lives_changed.connect(_on_lives_changed)

func _set_key_visibility() -> void:
	bw_keys.visible = !is_monster
	colored_keys.visible = !is_monster
	
	if is_monster: 
		return
	
	var limit = GameManager.team_keys

	for key in colored_keys.get_children():
		key.visible = int(key.name) < limit

	limit = GameManager.get_player_count()
	
	for key in range(bw_keys.get_child_count()):
		bw_keys.get_child(key).visible = key < limit

func _on_lives_changed(amount: int) -> void:
	# max team lives can change because players can leave the game
	live_bar.max_value = GameManager.max_team_lives
	live_bar.value = GameManager.team_lives
