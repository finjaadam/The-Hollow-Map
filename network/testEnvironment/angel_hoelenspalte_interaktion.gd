extends Node3D

const FISHING_MINIGAME = preload("res://ui/screens/minigames/fishing minigame/minigameFishing.tscn")

@onready var interaktions_prompt: InteractionPrompt = $Interaktions_Buchstabe
@onready var area_3d: Area3D = $Area3D 
@onready var klippen_sound_player: AudioStreamPlayer3D = $AngelWand_Player

var spieler_in_reichweite := false
var lokaler_spieler: General_Player = null

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	interaktions_prompt.hide_prompt()

func _process(_delta: float) -> void:
	if SceneLoader.is_paused:
		return
		
	_update_prompt()
	
	if spieler_in_reichweite and Input.is_action_just_pressed("interact"):
		if lokaler_spieler and not lokaler_spieler.is_minigaming and GameManager.fishingrod_in_inventory:
			starte_minigame()

func _on_body_entered(body: Node3D) -> void:
	if body is General_Player and body.is_multiplayer_authority():
		if body.ownRole == General_Player.Role.PLAYER:
			spieler_in_reichweite = true
			lokaler_spieler = body
			_update_prompt()

func _on_body_exited(body: Node3D) -> void:
	if body == lokaler_spieler:
		spieler_in_reichweite = false
		lokaler_spieler = null
		interaktions_prompt.hide_prompt()


func starte_minigame() -> void:
	interaktions_prompt.hide_prompt()
	
	lokaler_spieler.set_minigaming_mode(true)
	
	var minigame = FISHING_MINIGAME.instantiate()
	
	get_tree().current_scene.add_child(minigame)
	
	minigame.fishing_finished.connect(_on_minigame_finished.bind(minigame))

func _on_minigame_finished(success: bool, minigame_instance: Node) -> void:
	if success:
		minigame_instance.queue_free()
		await get_tree().process_frame
		
		print("Erfolg! Felsspalte gelöst.")
		if lokaler_spieler:
			lokaler_spieler.set_minigaming_mode(false)
			
		_entferne_spalte_fuer_alle.rpc()
			
		queue_free() 
	else:
		print("Fehltritt registriert, warte auf Minigame-Reset...")
		_play_klippen_sound.rpc()
		
@rpc("any_peer", "call_local", "reliable")
func _entferne_spalte_fuer_alle() -> void:
	queue_free()
		
@rpc("any_peer", "call_local", "reliable")
func _play_klippen_sound() -> void:
	if klippen_sound_player:
		if klippen_sound_player.playing:
			klippen_sound_player.stop()
		klippen_sound_player.play()

func _update_prompt() -> void:
	if not spieler_in_reichweite:
		return

	if GameManager.fishingrod_in_inventory:
		interaktions_prompt.show_prompt()
	else:
		interaktions_prompt.show_prompt(InteractionPrompt.PROMPT_FISHINGROD)
