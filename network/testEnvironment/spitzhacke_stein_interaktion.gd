extends Node3D
 
const STONE_MINIGAME = preload("res://ui/screens/minigames/stone minigame/minigameStone.tscn")

@onready var interaktions_prompt: InteractionPrompt = $Interaktions_Buchstabe
@onready var area_3d: Area3D = $Area3D 
@onready var stein_sound_player: AudioStreamPlayer3D = $Spitzhacke_Player

var spieler_in_reichweite := false
var lokaler_spieler: General_Player = null

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	interaktions_prompt.hide()

func _process(_delta: float) -> void:
	if SceneLoader.is_paused:
		return
		
	_update_prompt()
	
	if spieler_in_reichweite and Input.is_action_just_pressed("interact"):
		if lokaler_spieler and not lokaler_spieler.is_mining and GameManager.pickaxe_in_inventory:
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
	
	lokaler_spieler.set_mining_mode(true)
	
	var minigame = STONE_MINIGAME.instantiate()
	
	get_tree().current_scene.add_child(minigame)
	
	minigame.connect("minigame_finished", Callable(self, "_on_minigame_finished").bind(minigame))
	minigame.connect("stone_hit", Callable(self, "_on_stone_hit"))

func _on_minigame_finished(success: bool, minigame_instance: Node) -> void:
	if success:
		minigame_instance.queue_free()
		await get_tree().process_frame
		
		print("Erfolg! Rätsel am Stein gelöst.")
		if lokaler_spieler:
			lokaler_spieler.set_mining_mode(false)
			
		_entferne_stein_fuer_alle.rpc()

func _on_stone_hit() -> void:
	_play_stein_sound.rpc()

@rpc("any_peer", "call_local", "reliable")
func _entferne_stein_fuer_alle() -> void:
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func _play_stein_sound() -> void:
	if stein_sound_player:
		if stein_sound_player.playing:
			stein_sound_player.stop()
		stein_sound_player.play()

func _update_prompt() -> void:
	if not spieler_in_reichweite:
		return

	if GameManager.pickaxe_in_inventory:
		interaktions_prompt.show_prompt()
	else:
		interaktions_prompt.show_prompt(InteractionPrompt.PROMPT_PICKAXE)
