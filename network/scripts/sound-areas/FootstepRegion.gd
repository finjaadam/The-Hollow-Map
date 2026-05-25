extends Area3D

@export var surface_type: SoundManager.SurfaceType = SoundManager.SurfaceType.STONE

func _ready():
	add_to_group("footstep_region")
