extends CanvasLayer

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_label = $LiveLabel

@onready var bw_keys = $bw_keys
@onready var colored_keys = $colored_keys

func _ready() -> void:
	GameManager.keys_changed.connect(_set_key_visibility)
	GameManager.state_updated.connect(_set_key_visibility)
	
	_set_key_visibility()
	
	if is_monster: 
		return
	
	live_label.text = "Teamleben: %d" % GameManager.team_lives
	GameManager.lives_changed.connect(_on_lives_changed)

func _set_key_visibility() -> void:
	bw_keys.visible = !is_monster
	colored_keys.visible = !is_monster
	
	if is_monster: 
		return
	
	var limit = GameManager.team_keys

	for key in colored_keys.get_children():
		key.visible = key < limit
		print("color visibility: ", key.visible)

	limit = GameManager.get_player_count()
	
	for key in range(bw_keys.get_child_count()):
		bw_keys.get_child(key).visible = key < limit

func _on_lives_changed(amount: int) -> void:
	live_label.text = "Teamleben: %d" % amount
