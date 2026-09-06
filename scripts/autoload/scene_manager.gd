extends Node

## Singleton for scene management and transitions

signal scene_loaded(scene_name: String)
signal loading_progress(progress: float)

const MAIN_MENU = "res://scenes/main_menu/main_menu.tscn"
const SERVER_CONNECT = "res://scenes/server_connect/server_connect.tscn"
const LOBBY = "res://scenes/lobby/lobby.tscn"
const GAME_WORLD = "res://scenes/game/game_world.tscn"
const SETTINGS = "res://scenes/settings/settings_menu.tscn"

var _loading_scene_path: String = ""
var _is_loading: bool = false
var _progress_array: Array = []

func _process(_delta: float) -> void:
	if not _is_loading:
		return
		
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_loading_scene_path, _progress_array)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var progress: float = _progress_array[0] * 100.0
		loading_progress.emit(progress)
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		_is_loading = false
		loading_progress.emit(100.0)
		var packed_scene: PackedScene = ResourceLoader.load_threaded_get(_loading_scene_path)
		get_tree().change_scene_to_packed(packed_scene)
		scene_loaded.emit(_loading_scene_path)
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		_is_loading = false
		GameManager.report_error("Failed to load scene: " + _loading_scene_path)

## Asynchronously loads a scene with progress tracking
func change_scene(scene_path: String) -> void:
	if _is_loading:
		return
		
	GameManager.change_state(GameManager.GameState.LOADING)
	_loading_scene_path = scene_path
	_is_loading = true
	var err: int = ResourceLoader.load_threaded_request(scene_path)
	if err != OK:
		_is_loading = false
		GameManager.report_error("Failed to request scene load.")

## Immediately changes the scene (blocking)
func change_scene_instant(scene_path: String) -> void:
	var err: int = get_tree().change_scene_to_file(scene_path)
	if err == OK:
		scene_loaded.emit(scene_path)
	else:
		GameManager.report_error("Failed to change scene instantly.")
