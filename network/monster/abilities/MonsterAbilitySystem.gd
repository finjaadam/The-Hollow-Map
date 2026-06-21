class_name MonsterAbilitySystem
extends Node

## Holds a monster's abilities and their cooldowns, and listens for each
## ability's configured input action to trigger activate(). To add a new
## ability, just append another MonsterAbility resource to `abilities` in
## the inspector (or via add_ability()) - no other code needs to change.

signal ability_activated(index: int, ability: MonsterAbility)
signal ability_cooldown_updated(index: int, remaining: float, total: float)

@export var abilities: Array[MonsterAbility] = []

@onready var monster: General_Player = get_parent()

var _cooldown_remaining: Array[float] = []

func _ready() -> void:
	_cooldown_remaining.resize(abilities.size())
	_cooldown_remaining.fill(0.0)

func _process(delta: float) -> void:
	if not monster.is_multiplayer_authority():
		return
	if SceneLoader.is_paused or monster.is_movement_locked:
		return

	for i in abilities.size():
		if Input.is_action_just_pressed(abilities[i].input_action):
			_try_activate(i)

		if _cooldown_remaining[i] > 0.0:
			_cooldown_remaining[i] = max(_cooldown_remaining[i] - delta, 0.0)
			ability_cooldown_updated.emit(i, _cooldown_remaining[i], abilities[i].cooldown)

func add_ability(ability: MonsterAbility) -> void:
	abilities.append(ability)
	_cooldown_remaining.append(0.0)

func is_on_cooldown(index: int) -> bool:
	return _cooldown_remaining[index] > 0.0

func _try_activate(index: int) -> void:
	if is_on_cooldown(index):
		return

	var ability = abilities[index]
	ability.activate(monster)
	_cooldown_remaining[index] = ability.cooldown
	ability_activated.emit(index, ability)
	ability_cooldown_updated.emit(index, ability.cooldown, ability.cooldown)
