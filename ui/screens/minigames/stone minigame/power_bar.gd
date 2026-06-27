extends Control

signal power_selected(power: int, position: Vector2)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var power_number: Label = %PowerNumber
@onready var background_left: ColorRect = $"../../Background_(left)"

const MAX_POWER := 5
const CHARGE_SPEED := 5.0

var power := 0.0
var charging := false

func _ready() -> void:
	background_left.gui_input.connect(_on_background_left_gui_input)

	power = 0
	animated_sprite_2d.frame = 0
	power_number.text = "0"

func _process(delta: float) -> void:
	if charging:
		power += CHARGE_SPEED * delta
		power = min(power, MAX_POWER)

		var current_power := int(power)

		animated_sprite_2d.frame = current_power
		power_number.text = str(current_power)

func _on_background_left_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				charging = true
				power = 1.0  # Starte direkt bei Power 1
				animated_sprite_2d.frame = 1
				power_number.text = "1"

			else:
				charging = false

				# Sende aktuelle Mausposition mit
				power_selected.emit(int(power), event.position)

				# Reset
				power = 0
				animated_sprite_2d.frame = 0
				power_number.text = "0"
