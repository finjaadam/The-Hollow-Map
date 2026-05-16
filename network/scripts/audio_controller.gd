extends Node2D

const SAMPLE_RATE: int = 48000

var current_sample_rate: int = SAMPLE_RATE
var voice_playback: AudioStreamGeneratorPlayback = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_stream()
	record_voice(true)

func setup_stream() -> void:
	# Optionally we can get the sample rate from Steam
	# current_sample_rate = Steam.getVoiceOptimalSampleRate()

	var voice_stream_player := AudioStreamPlayer.new()
	add_child(voice_stream_player)
	voice_stream_player.stream = AudioStreamGenerator.new()
	voice_stream_player.stream.mix_rate = current_sample_rate
	voice_stream_player.play()
	voice_playback = voice_stream_player.get_stream_playback()

func record_voice(is_recording: bool) -> void:
	# If talking, suppress all other audio or voice comms from the Steam UI
	Steam.setInGameVoiceSpeaking(480, is_recording)
	if is_recording:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()

func check_for_voice() -> void:
	var voice_data: Dictionary = Steam.getVoice()
	if voice_data['result'] == Steam.VoiceResult.VOICE_RESULT_OK and voice_data['written']:
		process_voice_data.rpc(voice_data['buffer'])

# If using MultiplayerPeer, we will add this line
@rpc("any_peer", "call_remote", "unreliable")
func process_voice_data(voice_data: PackedByteArray) -> void:
	var decompressed_voice: Dictionary = Steam.decompressVoice(voice_data, current_sample_rate)

	if decompressed_voice['result'] == Steam.VoiceResult.VOICE_RESULT_OK and decompressed_voice['size'] > 0:
		var frames_to_push: PackedVector2Array = PackedVector2Array()
		frames_to_push.resize(decompressed_voice['size'] / 2)

		for i in range(0, decompressed_voice['size'], 2):
			var sample_int: int = decompressed_voice['uncompressed'].decode_s16(i)
			var amplitude: float = float(sample_int) / 32768.0
			frames_to_push[i / 2] = Vector2(amplitude,  amplitude)

		if voice_playback.get_frames_available() >= frames_to_push.size():
			voice_playback.push_buffer(frames_to_push)
		elif voice_playback.get_frames_available() > 0:
			voice_playback.push_buffer(frames_to_push.slice(0, voice_playback.get_frames_available()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_for_voice()
