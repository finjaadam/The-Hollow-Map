class_name MonsterAbility
extends Resource

## Base resource for a monster ability.
## To add a new ability: create a script that "extends MonsterAbility",
## override activate(), then create a .tres resource using that script
## and drop it into a MonsterAbilitySystem's `abilities` array.

@export var ability_name: String = "Ability"
@export var icon: Texture2D
@export var cooldown: float = 1.0
@export var input_action: StringName = &"ability_1"

## Override in a subclass to implement what the ability actually does.
func activate(monster: General_Player) -> void:
	pass
