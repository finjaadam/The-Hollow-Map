class_name MonsterAbilitySlot
extends Control

@onready var icon_rect: TextureRect = $Icon
@onready var cooldown_overlay: Control = $CooldownOverlay
@onready var abilityLabel: Label = $AbilityKey

func setup(ability: MonsterAbility) -> void:
	icon_rect.texture = ability.icon
	update_cooldown(0.0, ability.cooldown)
	abilityLabel.text = get_action_key_name(ability.input_action)

func update_cooldown(remaining: float, total: float) -> void:
	var fraction = 0.0 if total <= 0.0 else remaining / total
	cooldown_overlay.visible = fraction > 0.0
	cooldown_overlay.anchor_top = 1.0 - fraction # This moves the cooldown display

func get_action_key_name(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
	return ""
