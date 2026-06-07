extends CanvasLayer

@onready var key_label = $KeyLabel

func _ready() -> void:
	# ui is only visible for the player, not for the others
	if not is_multiplayer_authority():
		$UI.visible = false
		return
	
	key_label.text = "Schlüssel: %d" % TeamProperties.team_keys
	TeamProperties.keys_changed.connect(_on_keys_changed)


func _process(delta: float) -> void:
	pass

func _on_keys_changed(amount: int) -> void:
	key_label.text = "Schlüssel: %d" % amount
