extends MonsterAbility

## Reveals every player's silhouette through walls for `duration` seconds.
## material_overlay is a purely local rendering property (not replicated),
## so this only ever affects what the activating monster's own client sees.

@export var duration: float = 3.0
@export var silhouette_material: ShaderMaterial

func activate(monster: General_Player) -> void:
	var meshes = _collect_player_meshes(monster)
	for mesh in meshes:
		mesh.material_overlay = silhouette_material

	await monster.get_tree().create_timer(duration).timeout

	for mesh in meshes:
		if is_instance_valid(mesh):
			mesh.material_overlay = null

func _collect_player_meshes(monster: General_Player) -> Array[GeometryInstance3D]:
	var meshes: Array[GeometryInstance3D] = []
	for player in monster.get_tree().get_nodes_in_group("player"):
		_find_mesh_instances(player, meshes)
	return meshes

func _find_mesh_instances(node: Node, out: Array[GeometryInstance3D]) -> void:
	if node is GeometryInstance3D:
		out.append(node)
	for child in node.get_children():
		_find_mesh_instances(child, out)
