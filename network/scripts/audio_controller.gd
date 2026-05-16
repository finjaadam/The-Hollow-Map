extends Node

const SAMPLE_RATE: int = 48000
var voice_playback: AudioStreamGeneratorPlayback = null

func _enter_tree() -> void:
	set_multiplayer_authority(get_parent().name.to_int())

func _ready() -> void:
	# Everyone sets up a playback stream (to hear others)
	var voice_stream_player := AudioStreamPlayer.new()
	add_child(voice_stream_player)
	voice_stream_player.stream = AudioStreamGenerator.new()
	voice_stream_player.stream.mix_rate = SAMPLE_RATE
	voice_stream_player.play()
	voice_playback = voice_stream_player.get_stream_playback()

	# Only the authority records
	if is_multiplayer_authority():
		Steam.setInGameVoiceSpeaking(480, true)
		Steam.startVoiceRecording()

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	var voice_data: Dictionary = Steam.getVoice()
	if voice_data['result'] == Steam.VoiceResult.VOICE_RESULT_OK and voice_data['written']:
		send_voice.rpc(voice_data['buffer'])

@rpc("any_peer", "call_remote", "unreliable")
func send_voice(voice_data: PackedByteArray) -> void:
	if voice_playback == null:
		return
	var decompressed: Dictionary = Steam.decompressVoice(voice_data, SAMPLE_RATE)
	if decompressed['result'] != Steam.VoiceResult.VOICE_RESULT_OK or decompressed['size'] == 0:
		return
	var frames := PackedVector2Array()
	frames.resize(decompressed['size'] / 2)
	for i in range(0, decompressed['size'], 2):
		var sample: int = decompressed['uncompressed'].decode_s16(i)
		var amplitude: float = float(sample) / 32768.0
		frames[i / 2] = Vector2(amplitude, amplitude)
	var available: int = voice_playback.get_frames_available()
	if available >= frames.size():
		voice_playback.push_buffer(frames)
	elif available > 0:
		voice_playback.push_buffer(frames.slice(0, available))
