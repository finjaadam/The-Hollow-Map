extends CanvasLayer

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_label = $LiveLabel

@onready var bw_keys = $bw_keys
@onready var colored_keys = $colored_keys

@onready var flashlight_icon = $FlashlightIcon

func _ready() -> void:
	GameManager.keys_changed.connect(_set_key_visibility)
	GameManager.state_updated.connect(_set_key_visibility)
	
	_set_key_visibility()

	if is_monster:
		flashlight_icon.visible = false
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
		key.visible = int(key.name) < limit

	limit = GameManager.get_player_count()
	
	for key in range(bw_keys.get_child_count()):
		bw_keys.get_child(key).visible = key < limit

func _on_lives_changed(amount: int) -> void:
	live_label.text = "Teamleben: %d" % amount

func set_flashlight_cooldown(remaining: float, total: float) -> void:
	if is_monster:
		return
	if total <= 0:
		return
	var mat = flashlight_icon.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("fill_progress", 1.0 - remaining / total)
