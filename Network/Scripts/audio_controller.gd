# goes onto an audio_controller with an AudioStreamPlayer (mic input) child
extends Node
@onready var input : AudioStreamPlayer = $Input
var idx : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
@onready var output : AudioStreamPlayer = $Output
var buffer_size = 512

#func _enter_tree() -> void:
#	set_multiplayer_authority() # make sure this is set or stuff will absolutely go wrong
	
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
	buffer_size = effect.get_frames_available() 
	if not is_multiplayer_authority(): return
	# Capture regardless of playback state
	if effect.can_get_buffer(buffer_size):
		var data = effect.get_buffer(buffer_size)
		effect.clear_buffer()
		send_data.rpc(data)

# if not "call_remote," then the player will hear their own voice
# also don't try and do "unreliable_ordered." didn't work from my experience
@rpc("any_peer", "unreliable")
func send_data(data: PackedVector2Array):
	for i in range(data.size()):
		var sample = data[i]
		# Force mono mix to both ears
		var mono = (sample.x + sample.y) * 0.5
		playback.push_frame(Vector2(mono, mono))
