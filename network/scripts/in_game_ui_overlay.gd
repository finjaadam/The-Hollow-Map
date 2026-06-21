class_name InGameUIOverlay
extends CanvasLayer

const ABILITY_SLOT_SCENE := preload("res://network/monster/abilities/ability_slot.tscn")

@export var is_monster: bool

@onready var key_label = $KeyLabel
@onready var live_bar = $LiveBar

@onready var bw_keys = $bw_keys
@onready var colored_keys = $colored_keys

@onready var flashlight_icon = $FlashlightIcon
@onready var abilities_bar: HBoxContainer = $AbilitiesBar

@onready var message_label: Label = $MessageLabel
@onready var message_timer: Timer = $MessageTimer

@onready var damage_overlay: ColorRect = $DamageOverlay

var _damage_flash_tween: Tween

var _countdown_intro: String = ""
var _countdown_remaining: float = 0.0

func _process(delta: float) -> void:
	if _countdown_remaining <= 0.0:
		return

	_countdown_remaining = max(_countdown_remaining - delta, 0.0)
	if _countdown_remaining <= 0.0:
		message_label.visible = false
		return

	message_label.text = "%s Noch %d Sekunden..." % [_countdown_intro, ceil(_countdown_remaining)]

func _ready() -> void:
	GameManager.keys_changed.connect(_set_key_visibility)
	GameManager.state_updated.connect(_set_key_visibility)

	_set_key_visibility()

	abilities_bar.visible = is_monster
	message_label.visible = false
	message_timer.timeout.connect(_on_message_timer_timeout)

	
	live_bar.visible = !is_monster
	flashlight_icon.visible = !is_monster
	
	if is_monster:
		return
	
	live_bar.max_value = GameManager.max_team_lives
	live_bar.value = GameManager.team_lives
	
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
	# max team lives can change because players can leave the game
	live_bar.max_value = GameManager.max_team_lives
	live_bar.value = GameManager.team_lives

func set_flashlight_cooldown(remaining: float, total: float) -> void:
	if is_monster:
		return
	if total <= 0:
		return
	var mat = flashlight_icon.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("fill_progress", 1.0 - remaining / total)

## Shows a transient text message, e.g. "Du kannst dich für 5 Sekunden nicht bewegen!"
func show_message(text: String, duration: float) -> void:
	_countdown_remaining = 0.0 # stop any running countdown from overriding this
	message_label.text = text
	message_label.visible = true
	message_timer.start(duration)

func _on_message_timer_timeout() -> void:
	message_label.visible = false

## Shows `intro_text`, then keeps counting down the remaining seconds underneath
## it until `duration` has elapsed, e.g. "Du bist in eine Falle getreten! Noch 5 Sekunden..."
func show_countdown(intro_text: String, duration: float) -> void:
	message_timer.stop() # the countdown drives visibility itself, not the timer
	_countdown_intro = intro_text
	_countdown_remaining = duration
	message_label.text = "%s Noch %d Sekunden..." % [intro_text, ceil(duration)]
	message_label.visible = true

## Briefly tints the screen red, e.g. when the monster's damage aura ticks.
func flash_damage(peak_alpha: float = 0.35, fade_duration: float = 0.4) -> void:
	if _damage_flash_tween and _damage_flash_tween.is_running():
		_damage_flash_tween.kill()
	damage_overlay.color.a = peak_alpha
	_damage_flash_tween = create_tween()
	_damage_flash_tween.tween_property(damage_overlay, "color:a", 0.0, fade_duration)
