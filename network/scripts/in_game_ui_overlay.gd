class_name InGameUIOverlay
extends CanvasLayer

const ABILITY_SLOT_SCENE := preload("res://network/monster/abilities/ability_slot.tscn")

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_label = $LiveLabel

@onready var bw_keys = $bw_keys
@onready var colored_keys = $colored_keys

@onready var flashlight_icon = $FlashlightIcon
@onready var abilities_bar: HBoxContainer = $AbilitiesBar

func _ready() -> void:
	GameManager.keys_changed.connect(_set_key_visibility)
	GameManager.state_updated.connect(_set_key_visibility)

	_set_key_visibility()

	abilities_bar.visible = is_monster

	if is_monster:
		flashlight_icon.visible = false
		return

	live_label.text = "Teamleben: %d" % GameManager.team_lives
	GameManager.lives_changed.connect(_on_lives_changed)

## Spawns an icon/cooldown slot for every ability on `system` and keeps
## them updated as cooldowns change.
func bind_ability_system(system: MonsterAbilitySystem) -> void:
	for child in abilities_bar.get_children():
		child.queue_free()

	for ability in system.abilities:
		var slot: MonsterAbilitySlot = ABILITY_SLOT_SCENE.instantiate()
		abilities_bar.add_child(slot)
		slot.setup(ability)

	system.ability_cooldown_updated.connect(_on_ability_cooldown_updated)

func _on_ability_cooldown_updated(index: int, remaining: float, total: float) -> void:
	abilities_bar.get_child(index).update_cooldown(remaining, total)

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
