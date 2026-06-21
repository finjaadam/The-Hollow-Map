class_name Rune
extends CollectableItem

enum RuneType {
	COSMIC,
	NATURE,
	WATER
}

var rune_type: RuneType

@onready var cosmic_scene = $Area3D/CosmicScene
@onready var nature_scene = $Area3D/NatureScene
@onready var water_scene = $Area3D/WaterScene

func _ready() -> void:
	apply_visual()

func apply_visual() -> void:
	match rune_type:
		RuneType.COSMIC:
			cosmic_scene.visible = true
		RuneType.NATURE:
			nature_scene.visible = true
		RuneType.WATER:
			water_scene.visible = true

func _collect_item() -> void:
	print("Rune aufgehoben:", rune_type)
	GameManager.collect_rune.rpc(rune_type)
