extends Control

signal minigame_finished(success: bool)
signal stone_hit

var cursor = preload("res://assets/mouse_icons/pointer_b_shaded.png")
var cursor_pickaxe = preload("res://assets/mouse_icons/tool_pickaxe.png")

# Stone Grid Settings
const GRID_SIZE := 11  # 11x11 grid
const STONE_SIZE := 40.0  # Pixel per stone
const RADIUS_MULTIPLIER := 20.0  # Power 1 = 20px radius
const MIN_RADIUS := 20.0  # minimal radius

var stone_sprite_path: String = "res://assets/minispiel_stein/Stein_256x256.png"  # z.B. "res://assets/stone.png"
var key_sprite_path: String = "res://assets/lowpoly_sticks_-_free_download/key.png"    # z.B. "res://assets/key.png"

var background_left: ColorRect
var power_bar: Control
var stones: Array[Dictionary] = []
var stone_visuals: Array[Node] = []
var key_stone_index: int = -1
var _is_finished := false


func _ready():
	background_left = $"HFlowContainer/Background_(left)"
	power_bar = $"HFlowContainer/Background (right)/PowerBar"
	
	background_left.mouse_entered.connect(_on_color_rect_mouse_entered)
	background_left.mouse_exited.connect(_on_color_rect_mouse_exited)
	
	power_bar.power_selected.connect(_on_power_selected)

	# initialize grid and visuals
	_create_stone_grid()
	_create_stone_visuals()
	_place_key_randomly()

func _create_stone_grid() -> void:
	# calculate starting position to center the grid
	var total_width = GRID_SIZE * STONE_SIZE
	var total_height = GRID_SIZE * STONE_SIZE
	var start_x = (background_left.size.x - total_width) / 2.0
	var start_y = (background_left.size.y - total_height) / 2.0
	
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var stone_x = start_x + col * STONE_SIZE + STONE_SIZE / 2.0
			var stone_y = start_y + row * STONE_SIZE + STONE_SIZE / 2.0
			
			var stone_data = {
				"position": Vector2(stone_x, stone_y),
				"is_destroyed": false,
				"has_key": false,
				"index": stones.size()
			}
			stones.append(stone_data)

func _create_stone_visuals() -> void:
	var stone_container = Node2D.new()
	stone_container.name = "StoneContainer"
	background_left.add_child(stone_container)
	
	for i in range(stones.size()):
		var stone_visual: Node
		
		if stone_sprite_path != "":
			var sprite = Sprite2D.new()
			sprite.texture = load(stone_sprite_path)
			sprite.position = stones[i]["position"]
			sprite.centered = true
			sprite.scale = Vector2(STONE_SIZE / sprite.texture.get_size().x, STONE_SIZE / sprite.texture.get_size().y)
			stone_visual = sprite
		
		stone_container.add_child(stone_visual)
		stone_visuals.append(stone_visual)

func _place_key_randomly() -> void:
	key_stone_index = randi_range(0, stones.size() - 1)
	stones[key_stone_index]["has_key"] = true
	print("Schlüssel versteckt unter Stein %d" % key_stone_index)

func _on_power_selected(power: int, click_pos: Vector2) -> void:
	if _is_finished:
		return

	if power <= 0:
		return
	
	# calculate radius based on power
	var radius = max(power * RADIUS_MULTIPLIER, MIN_RADIUS)
	
	_destroy_stones_in_radius(click_pos, radius)

func _destroy_stones_in_radius(center: Vector2, radius: float) -> void:
	var destroyed_indices: Array[int] = []
	
	for i in range(stones.size()):
		if stones[i]["is_destroyed"]:
			continue
		
		var stone_pos = stones[i]["position"]
		var distance = center.distance_to(stone_pos)
		
		if distance <= radius:
			stones[i]["is_destroyed"] = true
			destroyed_indices.append(i)
			
			# Update visually
			if i < stone_visuals.size():
				var tween = create_tween()
				tween.tween_property(stone_visuals[i], "modulate", Color.TRANSPARENT, 0.3)
				tween.tween_callback(func(): stone_visuals[i].queue_free())
			
			print("Stein %d zerstört!" % i)
			
			# Debug: key found
			if stones[i]["has_key"]:
				print("🔑 SCHLÜSSEL GEFUNDEN!")
				_on_key_found()
	
	# Debug: show destroyed stones
	var destroyed_count = stones.filter(func(s): return s["is_destroyed"]).size()
	if destroyed_indices.size() > 0:
		stone_hit.emit()
	print("Insgesamt zerstört: %d / %d | Power: %d, Radius: %d" % [destroyed_count, stones.size(), destroyed_indices.size(), int(radius)])

func _on_key_found() -> void:
	if _is_finished:
		return
	_is_finished = true

	# show key under destroyed stone
	var key_stone_pos = stones[key_stone_index]["position"]
	
	# create key
	if key_sprite_path != "":
		var key_sprite = Sprite2D.new()
		key_sprite.texture = load(key_sprite_path)
		key_sprite.position = key_stone_pos
		key_sprite.centered = true
		key_sprite.scale = Vector2(0.05, 0.05)
		background_left.add_child(key_sprite)
		# small animation
		var tween = create_tween()
		tween.tween_property(key_sprite, "position:y", key_stone_pos.y - 30, 0.5)
		tween.tween_property(key_sprite, "position:y", key_stone_pos.y, 0.5)

	# small delay, to play key animation
	await get_tree().create_timer(2.0).timeout
	minigame_finished.emit(true)

func _on_color_rect_mouse_entered():
	Input.set_custom_mouse_cursor(cursor_pickaxe, Input.CURSOR_ARROW, Vector2(10, 8))

func _on_color_rect_mouse_exited():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(10, 8))
