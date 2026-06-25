extends MonsterAbility

## Places a monster_trap at the monster's feet, networked-spawned for all clients.

func activate(monster: General_Player) -> void:
	GameManager.add_spawn.rpc(_get_ground_position(monster), GameManager.spawn_type.TRAP)

## monster.global_position sits at the collision capsule's center, not its
## feet, so we raycast straight down to find the actual floor to place on.
func _get_ground_position(monster: General_Player) -> Vector3:
	var space_state := monster.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		monster.global_position,
		monster.global_position + Vector3.DOWN * 3.0
	)
	query.exclude = [monster]
	var result := space_state.intersect_ray(query)
	return result.position if result else monster.global_position
