extends Node3D

const FISHING_MINIGAME = preload("res://ui/screens/minigames/fishing minigame/minigameFishing.tscn")

@onready var interaktions_prompt: Label3D = %Interaktions_Buchstabe
@onready var area_3d: Area3D = $Area3D 
@onready var klippen_sound_player: AudioStreamPlayer3D = $AngelWand_Player

var spieler_in_reichweite := false
var lokaler_spieler: General_Player = null

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	interaktions_prompt.visible = false

func _process(_delta: float) -> void:
	if SceneLoader.is_paused:
		return
		
	if spieler_in_reichweite and Input.is_action_just_pressed("interact"):
		if lokaler_spieler and not lokaler_spieler.is_fishing:
			starte_minigame()

func _on_body_entered(body: Node3D) -> void:
	if body is General_Player and body.is_multiplayer_authority():
		spieler_in_reichweite = true
		lokaler_spieler = body
		interaktions_prompt.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == lokaler_spieler:
		spieler_in_reichweite = false
		lokaler_spieler = null
		interaktions_prompt.visible = false


func starte_minigame() -> void:
	interaktions_prompt.visible = false
	
	lokaler_spieler.set_fishing_mode(true)
	
	var minigame = FISHING_MINIGAME.instantiate()
	
	get_tree().current_scene.add_child(minigame)
	
	minigame.fishing_finished.connect(_on_minigame_finished.bind(minigame))

func _on_minigame_finished(success: bool, minigame_instance: Node) -> void:
	if success:
		minigame_instance.queue_free()
		await get_tree().process_frame
		
		print("Erfolg! Felsspalte gelöst.")
		if lokaler_spieler:
			lokaler_spieler.set_fishing_mode(false)
			
		queue_free() 
	else:
		print("Fehltritt registriert, warte auf Minigame-Reset...")
		_play_klippen_sound.rpc()
		
@rpc("any_peer", "call_local", "reliable")
func _play_klippen_sound() -> void:
	if klippen_sound_player:
		if klippen_sound_player.playing:
			klippen_sound_player.stop()
		klippen_sound_player.play()
