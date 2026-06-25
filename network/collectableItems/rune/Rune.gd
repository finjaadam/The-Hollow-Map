class_name Rune
extends CollectableItem

enum RuneType {
	COSMIC,
	NATURE,
	WATER
}

var rune_type: RuneType

@onready var cosmic_scene = $Area3D/CollisionShape3D/CosmicScene
@onready var nature_scene = $Area3D/CollisionShape3D/NatureScene
@onready var water_scene = $Area3D/CollisionShape3D/WaterScene

func _ready() -> void:
	super()
	apply_runetype()

func apply_runetype() -> void:
	match rune_type:
		RuneType.COSMIC:
			cosmic_scene.visible = true
			add_to_group("rune-cosmic")
		RuneType.NATURE:
			nature_scene.visible = true
			add_to_group("rune-nature")
		RuneType.WATER:
			water_scene.visible = true
			add_to_group("rune-water")

func _collect_item() -> void:
	super()
	GameManager.collect_rune.rpc(rune_type)
