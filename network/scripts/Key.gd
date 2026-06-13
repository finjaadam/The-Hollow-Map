extends Node3D

@onready var area: Area3D = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		GameManager.collect_key.rpc()
		queue_free()
