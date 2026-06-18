extends Control

var cursor = preload("res://assets/mouse_icons/pointer_b_shaded.png")
var cursor_pickaxe = preload("res://assets/mouse_icons/tool_pickaxe.png")

# Stone Grid Settings
const GRID_SIZE := 11  # 11x11 Gitter (121 Steine)
const STONE_SIZE := 40.0  # Pixel pro Stein
const RADIUS_MULTIPLIER := 20.0  # Power 1 = 40px Radius
const MIN_RADIUS := 20.0  # Minimaler Radius (garantiert zumindest einen Stein)

# Sprite-Pfade - ANPASSEN:
var stone_sprite_path: String = "res://ui/screens/minigames/stone minigame/Stein_256x256.png"  # z.B. "res://assets/stone.png"
var key_sprite_path: String = "res://ui/screens/minigames/stone minigame/key.png"    # z.B. "res://assets/key.png"

var background_left: ColorRect
var power_bar: Control
var stones: Array[Dictionary] = []  # Speichert Stone-Daten
var stone_visuals: Array[Node] = []  # Visuelle Darstellung der Steine
var key_stone_index: int = -1

# Stone-Farben
const STONE_COLOR = Color.GRAY
const DESTROYED_STONE_COLOR = Color.DARK_GRAY
const KEY_STONE_HIGHLIGHT = Color.YELLOW

func _ready():
	background_left = $"HFlowContainer/Background_(left)"
	power_bar = $"HFlowContainer/Background (right)/PowerBar"
	
	background_left.mouse_entered.connect(_on_color_rect_mouse_entered)
	background_left.mouse_exited.connect(_on_color_rect_mouse_exited)
	
	# Signal verbinden
	power_bar.power_selected.connect(_on_power_selected)
	
	# Steine initialisieren
	_create_stone_grid()
	_create_stone_visuals()
	_place_key_randomly()

func _create_stone_grid() -> void:
	# Berechne die Startposition für das Gitter (zentriert)
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
	# Erstelle visuelles Container-Node
	var stone_container = Node2D.new()
	stone_container.name = "StoneContainer"
	background_left.add_child(stone_container)
	
	for i in range(stones.size()):
		var stone_visual: Node
		
		# Verwende Sprite wenn Pfad gesetzt, sonst ColorRect
		if stone_sprite_path != "":
			var sprite = Sprite2D.new()
			sprite.texture = load(stone_sprite_path)
			sprite.position = stones[i]["position"]
			sprite.centered = true
			sprite.scale = Vector2(STONE_SIZE / sprite.texture.get_size().x, STONE_SIZE / sprite.texture.get_size().y)
			stone_visual = sprite
		else:
			var stone_rect = ColorRect.new()
			stone_rect.custom_minimum_size = Vector2(STONE_SIZE - 4, STONE_SIZE - 4)
			stone_rect.color = STONE_COLOR
			stone_rect.position = stones[i]["position"] - stone_rect.custom_minimum_size / 2.0
			stone_rect.modulate = Color.WHITE
			stone_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stone_visual = stone_rect
		
		stone_container.add_child(stone_visual)
		stone_visuals.append(stone_visual)

func _place_key_randomly() -> void:
	key_stone_index = randi_range(0, stones.size() - 1)
	stones[key_stone_index]["has_key"] = true
	print("Schlüssel versteckt unter Stein %d" % key_stone_index)

func _on_power_selected(power: int, click_pos: Vector2) -> void:
	if power <= 0:
		return
	
	# Berechne Radius basierend auf Power
	var radius = max(power * RADIUS_MULTIPLIER, MIN_RADIUS)
	
	# Zerstöre Steine im Radius
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
			
			# Update visuell
			if i < stone_visuals.size():
				var tween = create_tween()
				tween.tween_property(stone_visuals[i], "modulate", Color.TRANSPARENT, 0.3)
				tween.tween_callback(func(): stone_visuals[i].queue_free())
			
			print("Stein %d zerstört!" % i)
			
			# Wenn der Schlüssel unter diesem Stein war
			if stones[i]["has_key"]:
				print("🔑 SCHLÜSSEL GEFUNDEN!")
				_on_key_found()
	
	# Debug: Zeige zerstörte Steine
	var destroyed_count = stones.filter(func(s): return s["is_destroyed"]).size()
	print("Insgesamt zerstört: %d / %d | Power: %d, Radius: %d" % [destroyed_count, stones.size(), destroyed_indices.size(), int(radius)])

func _on_key_found() -> void:
	# Zeige den Schlüssel unter dem zerstörten Stein
	var key_stone_pos = stones[key_stone_index]["position"]
	
	# Erstelle Schlüssel-Visual
	if key_sprite_path != "":
		var key_sprite = Sprite2D.new()
		key_sprite.texture = load(key_sprite_path)
		key_sprite.position = key_stone_pos
		key_sprite.centered = true
		key_sprite.scale = Vector2(0.8, 0.8)
		background_left.add_child(key_sprite)
		# Animation: Springen lassen
		var tween = create_tween()
		tween.tween_property(key_sprite, "position:y", key_stone_pos.y - 30, 0.5)
		tween.tween_property(key_sprite, "position:y", key_stone_pos.y, 0.5)
	else:
		# Fallback: Gelbe Markierung wenn kein Sprite
		var key_marker = ColorRect.new()
		key_marker.custom_minimum_size = Vector2(40, 40)
		key_marker.color = Color.YELLOW
		key_marker.position = key_stone_pos - Vector2(20, 20)
		background_left.add_child(key_marker)

func _on_color_rect_mouse_entered():
	Input.set_custom_mouse_cursor(cursor_pickaxe, Input.CURSOR_ARROW, Vector2(10, 8))

func _on_color_rect_mouse_exited():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(10, 8))
