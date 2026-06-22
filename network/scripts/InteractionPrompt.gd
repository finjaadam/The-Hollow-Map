class_name InteractionPrompt
extends Label3D

func show_prompt() -> void:
	if !GameManager.fishingrod_in_inventory:
		text = "Du brauchst eine Angel"
	else:
		text = "E zum Interagieren"
	
	visible = true

func hide_prompt() -> void:
	visible = false
