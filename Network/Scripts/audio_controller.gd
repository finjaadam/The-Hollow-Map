extends Node

@onready var input: AudioStreamPlayer = $Input
@onready var output: AudioStreamPlayer = $Output

var idx: int
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback

const SAMPLE_RATE = 48000
const BUFFER_SIZE = 512
const MAX_QUEUE_SIZE = SAMPLE_RATE

var receive_queue: Array[Vector2] = []

func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().name.to_int())

func _ready() -> void:
	(output.stream as AudioStreamGenerator).mix_rate = SAMPLE_RATE
	output.play()
	playback = output.get_stream_playback()

	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(idx, 0)
		AudioServer.set_bus_mute(idx, true)

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		if effect.can_get_buffer(BUFFER_SIZE):
			var data = effect.get_buffer(BUFFER_SIZE)
			effect.clear_buffer()
			send_data.rpc(data)
	else:
		var frames_needed = int(SAMPLE_RATE * delta)
		var frames_to_push = min(min(receive_queue.size(), frames_needed), playback.get_frames_available())
		for i in range(frames_to_push):
			playback.push_frame(receive_queue[i])
		receive_queue = receive_queue.slice(frames_to_push)

@rpc("any_peer", "unreliable")
func send_data(data: PackedVector2Array):
	for i in range(data.size()):
		var mono = (data[i].x + data[i].y) * 0.5
		receive_queue.append(Vector2(mono, mono))
	if receive_queue.size() > MAX_QUEUE_SIZE:
		receive_queue = receive_queue.slice(receive_queue.size() - MAX_QUEUE_SIZE)
