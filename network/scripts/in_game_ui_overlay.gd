extends CanvasLayer

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_label = $LiveLabel

@onready var bw_keys = $bw_keys
@onready var colored_keys = $colored_keys

func _ready() -> void:
	GameManager.keys_changed.connect(_on_keys_changed)
	GameManager.state_updated.connect(_set_key_visibility_on_ready)
	
	_set_key_visibility_on_ready()
	
	if is_monster: 
		return
	
	live_label.text = "Teamleben: %d" % GameManager.team_lives
	GameManager.lives_changed.connect(_on_lives_changed)

func _set_key_visibility_on_ready() -> void:
	bw_keys.visible = !is_monster
	colored_keys.visible = !is_monster
	
	if is_monster: 
		return
	
	var limit = GameManager.get_player_count()

	for i in range(colored_keys.get_child_count() - 1, limit - 1, -1):
		var child = colored_keys.get_child(i)
		colored_keys.remove_child(child)
		child.queue_free()
	
	limit = GameManager.get_player_count()

	for i in range(bw_keys.get_child_count() - 1, limit - 1, -1):
		var child = (bw_keys.get_child(i))
		bw_keys.remove_child(child)
		child.queue_free()
	
	# at the beginning no keys are collected
	for key in colored_keys.get_children():
		key.visible = false

func _on_keys_changed(amount: int) -> void:
	if amount == 0: 
		return
	colored_keys.get_child(amount - 1).visible = true

func _on_lives_changed(amount: int) -> void:
	live_label.text = "Teamleben: %d" % amount
