class_name InteractionPrompt
extends Label3D

const PROMPT_DEFAULT := "default"
const PROMPT_FISHINGROD := "fishingrod"
const PROMPT_PICKAXE := "pickaxe"
const PROMPT_RUNE := "rune"

func show_prompt(required_item: String = PROMPT_DEFAULT) -> void:
	match required_item:
		PROMPT_FISHINGROD:
			text = "Du brauchst eine Angel"
		PROMPT_PICKAXE:
			text = "Du brauchst eine Spitzhacke"
		PROMPT_RUNE:
			text = "Du brauchst drei Runen"
		_:
			text = "E zum Interagieren"
	
	visible = true

func hide_prompt() -> void:
	visible = false
