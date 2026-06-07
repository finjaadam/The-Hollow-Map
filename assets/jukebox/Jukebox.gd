extends Area3D

@export var sounds: Array[AudioStream]

@onready var audio: RaytracedAudioPlayer3D = $Audio

func _ready():
	audio.enabled.connect(BusManager.route_to_SFX_bus.bind(audio))

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		var idx = randi() % sounds.size()
		_play_jukebox.rpc(idx)

@rpc("any_peer", "call_local", "unreliable")
func _play_jukebox(sound_index: int):
	audio.stop()
	audio.stream = sounds[sound_index]
	audio.play()
