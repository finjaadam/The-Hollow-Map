extends Node

const MENU_MUSIC = preload("res://audio/music/menu/menu_music.mp3")
const BUTTON_CLICK = preload("res://audio/soundfx/menu/button_click.mp3")
const AMBIENT_LIBRARY: AudioLibrary = preload("res://audio/music/menu/ambient/ambient_sounds.tres")

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _ambient_timer: Timer


func _ready() -> void:
	_setup_players()
	# React to scene changes via SceneLoader
	SceneLoader.scene_loading_finished.connect(_on_scene_loaded)
	# Wait one frame so the first scene is fully initialized
	await get_tree().process_frame
	_on_scene_loaded()


func _on_scene_loaded(_path: String = "") -> void:
	var scene := get_tree().current_scene
	if not scene:
		return
	connect_button_sounds(scene)
	if scene.is_in_group("main_menu"):
		play_menu_music()
	else:
		stop_menu_music()

# Recursively connect all buttons and dropdowns in the given node tree to the click sound
func connect_button_sounds(root: Node) -> void:
	for button in root.find_children("*", "Button", true, false):
		if not button.pressed.is_connected(play_button_click):
			button.pressed.connect(play_button_click)
	for option in root.find_children("*", "OptionButton", true, false):
		if not option.item_selected.is_connected(func(_i): play_button_click()):
			option.item_selected.connect(func(_i): play_button_click())
	for slider in root.find_children("*", "Slider", true, false):
		if not slider.drag_ended.is_connected(func(_i): play_button_click()):
			slider.drag_ended.connect(func(_i): play_button_click())

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


func _start_ambient_timer() -> void:
	if AMBIENT_LIBRARY.menu_ambient.is_empty():
		return
	# Don't restart if already running
	if _ambient_timer and not _ambient_timer.is_stopped():
		return
	if not _ambient_timer:
		_ambient_timer = Timer.new()
		_ambient_timer.one_shot = true
		_ambient_timer.timeout.connect(_on_ambient_timer_timeout)
		add_child(_ambient_timer)
	_restart_ambient_timer()


func _restart_ambient_timer() -> void:
	_ambient_timer.wait_time = randf_range(5.0, 20.0)
	_ambient_timer.start()


func _on_ambient_timer_timeout() -> void:
	if AMBIENT_LIBRARY.menu_ambient.is_empty():
		return

	_ambient_player.volume_db = -4.5
	# Pick a random ambient sound from the list
	var stream = AMBIENT_LIBRARY.menu_ambient[randi() % AMBIENT_LIBRARY.menu_ambient.size()]
	_ambient_player.stream = stream
	_ambient_player.play()

	# Schedule next ambient sound after current one finishes
	_ambient_player.finished.connect(_restart_ambient_timer, CONNECT_ONE_SHOT)


func play_menu_music() -> void:
	if _music_player.playing:
		return
	_music_player.stream = MENU_MUSIC
	_music_player.volume_db = 10.0
	_music_player.finished.connect(_music_player.play, CONNECT_ONE_SHOT)
	_music_player.play()
	_start_ambient_timer()


func stop_menu_music() -> void:
	if (_music_player.finished.is_connected(_music_player.play)):
		_music_player.finished.disconnect(_music_player.play)
	_music_player.stop()
	_ambient_player.stop()
	if _ambient_timer:
		_ambient_timer.stop()


func play_button_click() -> void:
	_sfx_player.stream = BUTTON_CLICK
	_sfx_player.volume_db = -10.0
	_sfx_player.play()
