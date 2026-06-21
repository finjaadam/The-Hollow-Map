extends General_Player

@onready var ability_system: MonsterAbilitySystem = $AbilitySystem

# do NOT create a _ready() function since it will overwrite the _ready from
# General_Player --> Use _on_ready() instead
func _on_ready() -> void:
	add_to_group("monster")
	ownRole = Role.MONSTER
	if is_multiplayer_authority():
		$Model/BlobMonster.visible = false # you don't see model
	else:
		$Model/BlobMonster.visible = true # everyone else can see model

# Override general setup and add the ability system to it
func _setup_ui() -> void:
	super._setup_ui()
	var overlay = canvas as InGameUIOverlay
	overlay.bind_ability_system(ability_system)
