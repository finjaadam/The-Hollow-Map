extends Node

const MENU_MUSIC_PATH = "res://audio/music/menu/menu_music.mp3"
const AMBIENT_DIR = "res://audio/music/menu/ambient/"
const BUTTON_CLICK_PATH = "res://audio/soundfx/menu/button_click.mp3"

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _ambient_timer: Timer
var _ambient_sounds: Array[AudioStream] = []


func _ready() -> void:
	_setup_players()
	_load_ambient_sounds()
	_start_ambient_timer()
	play_menu_music()


func _setup_players() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.name = "MenuMusicPlayer"
	add_child(_music_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	_sfx_player.name = "MenuSFXPlayer"
	add_child(_sfx_player)

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Music"
	_ambient_player.name = "MenuAmbientPlayer"
	add_child(_ambient_player)


func _load_ambient_sounds() -> void:
	var dir = DirAccess.open(AMBIENT_DIR)
	if not dir:
		print("MenuSoundManager: Directory not found: ", AMBIENT_DIR)
		return
		
	for file in dir.get_files():
		if not file.get_extension().to_lower() == "mp3":
			continue
		var stream = load(AMBIENT_DIR + file)
		if stream:
			_ambient_sounds.append(stream)


func _start_ambient_timer() -> void:
	if _ambient_sounds.is_empty():
		return
	_ambient_timer = Timer.new()
	_ambient_timer.one_shot = true
	_ambient_timer.timeout.connect(_on_ambient_timer_timeout)
	add_child(_ambient_timer)
	_restart_ambient_timer()


func _restart_ambient_timer() -> void:
	_ambient_timer.wait_time = randf_range(5.0, 20.0)
	_ambient_timer.start()


func _on_ambient_timer_timeout() -> void:
	if _ambient_sounds.is_empty():
		return

	_ambient_player.volume_db = -4.5
	var stream = _ambient_sounds[randi() % _ambient_sounds.size()]
	_ambient_player.stream = stream
	_ambient_player.play()

	_ambient_player.finished.connect(_restart_ambient_timer, CONNECT_ONE_SHOT)


func play_menu_music() -> void:
	if _music_player.playing:
		return
	var stream = load(MENU_MUSIC_PATH)
	if stream:
		_music_player.stream = stream
		_music_player.volume_db = 4.5
		_music_player.finished.connect(_music_player.play)
		_music_player.play()


func stop_menu_music() -> void:
	_music_player.stop()
	if _ambient_timer:
		_ambient_timer.stop()


func play_button_click() -> void:
	var stream = load(BUTTON_CLICK_PATH)
	if stream:
		_sfx_player.stream = stream
		_sfx_player.volume_db = -10.0
		_sfx_player.play()
