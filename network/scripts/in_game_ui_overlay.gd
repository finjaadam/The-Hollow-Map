extends CanvasLayer

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_label = $LiveLabel

@onready var bw_keys = $bw_keys
@onready var colored_keys = $colored_keys

func _ready() -> void:
	bw_keys.visible = !is_monster
	colored_keys.visible = !is_monster
	
	live_label.visible = !is_monster
	
	for key in colored_keys.get_children():
		key.visible = false
	
	if is_monster: return
	
	key_label.text = "Schlüssel: %d" % GameManager.team_keys
	GameManager.keys_changed.connect(_on_keys_changed)
	
	live_label.text = "Teamleben: %d" % GameManager.team_lives
	GameManager.lives_changed.connect(_on_lives_changed)

func _on_keys_changed(amount: int) -> void:
	
	if amount == 0: 
		return
	print(colored_keys.get_child(amount).visible)
	colored_keys.get_child(amount - 1).visible = true

func _on_lives_changed(amount: int) -> void:
	live_label.text = "Teamleben: %d" % amount
