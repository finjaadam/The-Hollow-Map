extends Control

@onready var audio_button = $CenterContainer/VBoxContainer/OptionsButtons/AudioButton
@onready var video_button = $CenterContainer/VBoxContainer/OptionsButtons/VideoButton
@onready var controls_button = $CenterContainer/VBoxContainer/OptionsButtons/ControlsButton
@onready var language_option = $CenterContainer/VBoxContainer/LanguageRow/LanguageOption
@onready var back_button = $CenterContainer/VBoxContainer/BackButton

@onready var title_label = $CenterContainer/VBoxContainer/Title
@onready var language_label = $CenterContainer/VBoxContainer/LanguageRow/LanguageLabel

const LANGS = {
	"en": "English",
	"de": "Deutsch",
}

func _ready():
	# Add to translatable group for instant language updates
	add_to_group("translatable")
	
	if audio_button: audio_button.pressed.connect(_on_audio_pressed)
	if video_button: video_button.pressed.connect(_on_video_pressed)
	if controls_button: controls_button.pressed.connect(_on_controls_pressed)
	if back_button: back_button.pressed.connect(_on_back_pressed)

	if language_option:
		_setup_language_options()
		language_option.item_selected.connect(_on_language_selected)
	
	# BR1 Fix: Connect to language changes
	Settings.setting_changed.connect(_on_setting_changed)

	_setup_navigation()
	_apply_translations()

	if audio_button:
		audio_button.grab_focus()

func _on_setting_changed(setting_name: String, value):
	if setting_name == "language":
		_apply_translations()

func _setup_language_options() -> void:
	if not language_option: return
	language_option.clear()
	var current: String = str(Settings.get_setting("language", "de"))
	var selected_index = 0
	var i = 0
	for code in LANGS.keys():
		language_option.add_item(LANGS[code])
		language_option.set_item_metadata(i, code)
		if code == current:
			selected_index = i
		i += 1
	language_option.selected = selected_index

func _on_language_selected(index: int) -> void:
	if not language_option: return
	var code = language_option.get_item_metadata(index)
	if typeof(code) == TYPE_STRING and code != "":
		var new_language = String(code)
		var current_language = str(Settings.get_setting("language", "de"))
		
		# Only change if it's actually different
		if new_language != current_language:
			print("Changing language from ", current_language, " to ", new_language)
			Settings.set_setting("language", new_language)
			TranslationServer.set_locale(new_language)
			
			# Wait one frame to ensure locale is set
			await get_tree().process_frame
			
			# Force update translations immediately
			_apply_translations()
			
			# Also force update on all other open scenes/nodes
			get_tree().call_group("translatable", "_apply_translations")
			
			# Debug: Test if translation is working
			print("Testing translation: ", tr("SETTINGS"))

func _apply_translations() -> void:
	if title_label: title_label.text = tr("SETTINGS")
	if language_label: language_label.text = tr("LANGUAGE")
	if audio_button: audio_button.text = tr("AUDIO_SETTINGS")
	if video_button: video_button.text = tr("VIDEO_SETTINGS")
	if controls_button: controls_button.text = tr("CONTROLS_SETTINGS")
	if back_button: back_button.text = tr("BACK")

func _setup_navigation() -> void:
	if not audio_button or not video_button or not controls_button or not language_option or not back_button:
		return
	audio_button.focus_neighbor_top = back_button.get_path()
	audio_button.focus_neighbor_bottom = video_button.get_path()
	video_button.focus_neighbor_top = audio_button.get_path()
	video_button.focus_neighbor_bottom = controls_button.get_path()
	controls_button.focus_neighbor_top = video_button.get_path()
	controls_button.focus_neighbor_bottom = language_option.get_path()
	language_option.focus_neighbor_top = controls_button.get_path()
	language_option.focus_neighbor_bottom = back_button.get_path()
	back_button.focus_neighbor_top = language_option.get_path()
	back_button.focus_neighbor_bottom = audio_button.get_path()

func _on_audio_pressed(): SceneLoader.goto_scene("res://ui/screens/menu/AudioMenu.tscn", false)
func _on_video_pressed(): SceneLoader.goto_scene("res://ui/screens/menu/VideoMenu.tscn", false)
func _on_controls_pressed(): SceneLoader.goto_scene("res://ui/screens/menu/ControlsMenu.tscn", false)
func _on_back_pressed(): SceneLoader.goto_scene("res://ui/screens/menu/MainMenu.tscn", false)
