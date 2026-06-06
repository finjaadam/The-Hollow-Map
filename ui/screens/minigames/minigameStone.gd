extends Control

var cursor = preload("res://assets/mouse_icons/pointer_b_shaded.png")
var cursor_pickaxe = preload("res://assets/mouse_icons/tool_pickaxe.png")

func _ready():
	$Background.mouse_entered.connect(_on_color_rect_mouse_entered)
	$Background.mouse_exited.connect(_on_color_rect_mouse_exited)

func _on_color_rect_mouse_entered():
	Input.set_custom_mouse_cursor(cursor_pickaxe, Input.CURSOR_ARROW, Vector2(10, 8))

func _on_color_rect_mouse_exited():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(10, 8))
