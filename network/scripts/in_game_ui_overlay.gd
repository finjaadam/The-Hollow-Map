extends CanvasLayer

@onready var key_label = $KeyLabel

func _ready() -> void:
	key_label.text = "Schlüssel: %d" % TeamProperties.team_keys
	TeamProperties.keys_changed.connect(_on_keys_changed)


func _process(delta: float) -> void:
	pass

func _on_keys_changed(amount: int) -> void:
	key_label.text = "Schlüssel: %d" % amount
