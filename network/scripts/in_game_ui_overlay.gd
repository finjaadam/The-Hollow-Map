extends CanvasLayer

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_label = $LiveLabel

func _ready() -> void:
	key_label.visible = !is_monster
	live_label.visible = !is_monster
	
	if is_monster: return
	
	key_label.text = "Schlüssel: %d" % GameManager.team_keys
	GameManager.keys_changed.connect(_on_keys_changed)
	
	live_label.text = "Teamleben: %d" % GameManager.team_lives
	GameManager.lives_changed.connect(_on_lives_changed)

func _on_keys_changed(amount: int) -> void:
	key_label.text = "Schlüssel: %d" % amount

func _on_lives_changed(amount: int) -> void:
	live_label.text = "Teamleben: %d" % amount
