extends Control

# Signal, das dem Hauptspiel informiert, wenn man gewonnen hat
signal fishing_finished(success: bool)

@onready var haken: Sprite2D = %Haken 
@onready var schnur: Line2D = %Angelschnur
@onready var angel_rute: Sprite2D = %Angelrute 
@onready var status_label: Label = $StatusLabel
@onready var reset_timer: Timer = $ResetTimer

var game_active := true

func start_game() -> void:
	game_active = true
	status_label.text = "" 
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Init Angelschnur
	schnur.clear_points()
	schnur.add_point(Vector2.ZERO)
	schnur.add_point(Vector2.ZERO)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#Angelschnur-Verbindung
	schnur.clear_points()
	schnur.add_point(Vector2.ZERO) # Punkt 0 (Start)
	schnur.add_point(Vector2.ZERO) # Punkt 1 (Ende am Haken)

func _process(_delta: float) -> void:
	if game_active:
		haken.position = get_local_mouse_position()
		
		var globale_spitze = %RutenSpitze.global_position
		var globales_oehr = %HakenOehr.global_position
		
		schnur.set_point_position(0, schnur.to_local(globale_spitze))
		schnur.set_point_position(1, schnur.to_local(globales_oehr))

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# WAND BERÜHRT (Verloren)
func _on_area_2d_wand_area_entered(_area: Area2D) -> void:
	if game_active:
		print("Wand berührt")
		game_active = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Maus wieder zeigen
		
		status_label.text = "Wand berührt! Das Monster hat dich gehört..."
		
		fishing_finished.emit(false) # Dem Hauptspiel sagen: "Verloren!"
		
		reset_timer.start()

# SCHLÜSSEL ERREICHT (Gewonnen)
func _on_area_2d_key_area_entered(_area: Area2D) -> void:
	if game_active:
		print("Schlüssel gefangen")
		game_active = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Maus wieder zeigen
		
		status_label.text = "Erfolgreich! Schlüssel erhalten."
		
		fishing_finished.emit(true) # Dem Hauptspiel sagen: "Gewonnen!"


func _on_reset_timer_timeout() -> void:
	start_game()
