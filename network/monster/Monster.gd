extends General_Player

@onready var ability_system: MonsterAbilitySystem = $AbilitySystem

## Damage aura: deals `aura_damage` to the shared team life pool every
## `aura_tick_interval` seconds while at least one player is within
## `aura_radius`. Exported so designers can tune it from the scene.
@export var aura_damage: int = 1
@export var aura_tick_interval: float = 1.0
@export var aura_radius: float = 5.0

var _aura_timer: Timer

# do NOT create a _ready() function since it will overwrite the _ready from
# General_Player --> Use _on_ready() instead
func _on_ready() -> void:
	add_to_group("monster")
	ownRole = Role.MONSTER
	if is_multiplayer_authority():
		$Model/BlobMonster.visible = false # you don't see model
	else:
		$Model/BlobMonster.visible = true # everyone else can see model

	_aura_timer = Timer.new()
	_aura_timer.wait_time = aura_tick_interval
	_aura_timer.timeout.connect(_on_aura_tick)
	add_child(_aura_timer)
	_aura_timer.start()

func _on_aura_tick() -> void:
	if not multiplayer.is_server():
		return
	for player in get_tree().get_nodes_in_group("player"):
		if global_position.distance_to(player.global_position) <= aura_radius:
			GameManager.remove_lives(aura_damage)
			return

# Override general setup and add the ability system to it
func _setup_ui() -> void:
	super._setup_ui()
	var overlay = canvas as InGameUIOverlay
	overlay.bind_ability_system(ability_system)
