class_name InteractionPrompt
extends Label3D

const PROMPT_DEFAULT := "default"
const PROMPT_FISHINGROD := "fishingrod"
const PROMPT_PICKAXE := "pickaxe"

func show_prompt(required_item: String = PROMPT_DEFAULT) -> void:
	match required_item:
		PROMPT_FISHINGROD:
			text = "Du brauchst eine Angel"
		PROMPT_PICKAXE:
			text = "Du brauchst eine Spitzhacke"
		_:
			text = "E zum Interagieren"
	
	visible = true

func hide_prompt() -> void:
	visible = false
