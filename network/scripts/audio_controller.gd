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
	# Decompressed Voice from Steam is 16-bit PCM --> 2 Bytes per Sample
	# Godot needs Vector2 Array in order to work with Audio --> 1 Vector = 1 Audio Sample
	# x-Value of Vector2 is left ear, y-Value of Vector2 is right ear
	# 1000 Bytes Audio = 500 Samples = 500 Vectors that are need --> divide by 2
	frames.resize(decompressed['size'] / 2)
	
	for i in range(0, decompressed['size'], 2):							# 2 Bytes at a time
		var sample: int = decompressed['uncompressed'].decode_s16(i)	# Decode 2 bytes to signed 16-bit int
		var amplitude: float = float(sample) / 32768.0					# 16 bit = 32768 Values, normalize to -1 and +1
		frames[i / 2] = Vector2(amplitude, amplitude)					# Copy Value to left + right ear
	
	# Check how much new Data can be pushed to Playback to prevent overflow
	var available: int = voice_playback.get_frames_available()

	# Push all data you have without overflowing
	if available >= frames.size():
		voice_playback.push_buffer(frames)
	elif available > 0:
		voice_playback.push_buffer(frames.slice(0, available))
