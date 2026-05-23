extends CanvasLayer

@onready var progress_bar = $ColorRect/CenterContainer/VBox/ProgressBar
@onready var loading_label = $ColorRect/CenterContainer/VBox/LoadingLabel
@onready var progress_label = $ColorRect/CenterContainer/VBox/ProgressLabel

var loading_texts = [
	"Lädt...",
	"Höhle vorbereiten...",
	"Monster aufwecken...",
	"Spieler verängstigen...",
    "Schlüssel verteilen..."
]

func _ready():
	randomize()
	if loading_label:
		loading_label.text = loading_texts[randi() % loading_texts.size()]
	if progress_bar:
		progress_bar.value = 0.0
	if progress_label:
		progress_label.text = "0%"

func update_progress(p: float) -> void:
	p = clamp(p, 0.0, 1.0)
	if is_instance_valid(progress_bar):
		progress_bar.value = p
	if is_instance_valid(progress_label):
		progress_label.text = "%d%%" % (p * 100)
	if is_instance_valid(loading_label):
		var text_index = int(p * (loading_texts.size() - 1))
		loading_label.text = loading_texts[text_index]
