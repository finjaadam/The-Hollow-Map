extends Area3D

@export var sounds: Array[AudioStream]

@onready var audio: AudioStreamPlayer3D = $Audio

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		audio.stop()
		audio.stream = sounds.pick_random()
		audio.play()
