extends Area3D

@export var surface_type: AreaSoundManager.SurfaceType = AreaSoundManager.SurfaceType.STONE

func _ready():
	add_to_group("footstep_region")
