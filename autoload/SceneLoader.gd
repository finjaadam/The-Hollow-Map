extends CanvasLayer

signal scene_loading_started(scene_path: String)
signal scene_loading_progress(progress: float)
signal scene_loading_finished(scene_path: String)

var current_scene: Node
var loading_screen_scene: PackedScene

func _ready():
	current_scene = get_tree().current_scene
	if ResourceLoader.exists("res://ui/screens/LoadingScreen.tscn"):
		loading_screen_scene = load("res://ui/screens/LoadingScreen.tscn")

func goto_scene(path: String, show_loading: bool = true) -> void:
	scene_loading_started.emit(path)
	var should_show: bool = show_loading and Settings.should_show_loading_screen()
	if should_show:
		call_deferred("_deferred_goto_scene_with_loading", path)
	else:
		call_deferred("_deferred_goto_scene", path)
		
func goto_preloaded_scene(instance: Node, path: String) -> void:
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	get_tree().root.add_child(instance)
	get_tree().current_scene = instance
	current_scene = instance
	scene_loading_finished.emit(path)

func _deferred_goto_scene(path: String) -> void:
	var res: Resource = load(path)
	if res == null:
		push_error("Failed to load scene: %s" % path)
		return
	var inst: Node = (res as PackedScene).instantiate()
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	get_tree().root.add_child(inst)
	get_tree().current_scene = inst
	current_scene = inst
	scene_loading_finished.emit(path)

func _deferred_goto_scene_with_loading(path: String) -> void:
	var loading: Node = null
	if loading_screen_scene:
		loading = loading_screen_scene.instantiate()
		add_child(loading)

	var req: int = ResourceLoader.load_threaded_request(path)
	if req != OK:
		push_error("Threaded request failed for: %s" % path)
		if loading:
			loading.queue_free()
		return

	while true:
		var progress = []
		var s: int = ResourceLoader.load_threaded_get_status(path, progress)
		if progress.size() > 0:
			scene_loading_progress.emit(progress[0])
			if loading and loading.has_method("update_progress"):
				loading.call_deferred("update_progress", progress[0])

		if s == ResourceLoader.THREAD_LOAD_LOADED:
			break
		elif s == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: %s" % path)
			if loading:
				loading.queue_free()
			return

		await get_tree().process_frame

	var res: Resource = ResourceLoader.load_threaded_get(path)
	var inst: Node = (res as PackedScene).instantiate()
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	get_tree().root.add_child(inst)
	get_tree().current_scene = inst
	current_scene = inst

	if loading:
		loading.queue_free()
	scene_loading_finished.emit(path)

func reload_current_scene():
	var cs: Node = get_tree().current_scene
	if cs:
		var path: String = ""
		if cs is Node:
			path = cs.scene_file_path if cs.scene_file_path != "" else cs.get_scene_file_path()
		if path != "":
			goto_scene(path)

func get_current_scene() -> Node:
	return current_scene
