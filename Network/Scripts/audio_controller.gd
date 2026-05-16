# goes onto an audio_controller with an AudioStreamPlayer (mic input) child
extends Node
@onready var input : AudioStreamPlayer = $Input
var idx : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
@onready var output : AudioStreamPlayer3D = $Output
var buffer_size = 512
var jitter_buffer : Array = []
const JITTER_TARGET = 4  # tune this (number of chunks to pre-buffer)

# func _enter_tree() -> void:
# 	set_multiplayer_authority() # make sure this is set or stuff will absolutely go wrong
	
func _ready() -> void:
	# we only want to initalize the mic for the peer using it
	if (is_multiplayer_authority()):
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(idx, 0)
		# replace 0 with whatever index the capture effect is
		AudioServer.set_bus_mute(idx, true)
	# playback variable will be needed for playback on other peers
	playback = output.get_stream_playback()

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if effect.can_get_buffer(buffer_size):
			send_data.rpc(effect.get_buffer(buffer_size))
		effect.clear_buffer()
	else:
		# Wait until buffer has enough to smooth over jitter
		if jitter_buffer.size() >= JITTER_TARGET:
			var chunk : PackedVector2Array = jitter_buffer.pop_front()
			for i in range(chunk.size()):
				playback.push_frame(chunk[i])

# if not "call_remote," then the player will hear their own voice
# also don't try and do "unreliable_ordered." didn't work from my experience
@rpc("any_peer", "call_remote", "unreliable")
func send_data(data : PackedVector2Array):
	jitter_buffer.append(data)
