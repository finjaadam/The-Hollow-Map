extends MonsterAbility

## Temporarily boosts the monster's movement speed.

@export var duration: float = 5.0
@export var speed_multiplier: float = 1.8

func activate(monster: General_Player) -> void:
	var original_speed = monster.speed
	monster.speed = original_speed * speed_multiplier
	await monster.get_tree().create_timer(duration).timeout
	monster.speed = original_speed
