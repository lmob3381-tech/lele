extends Node
class_name MissionBase

# Base class for all mission types
@export var mission_name: String = "Mission"
@export var mission_description: String = ""
@export var difficulty: int = 1 # 1-5
@export var time_limit: float = 300.0 # 5 minutes default
@export var horror_intensity_multiplier: float = 1.0

enum MissionStatus {NOT_STARTED, IN_PROGRESS, COMPLETED, FAILED}

var status: MissionStatus = MissionStatus.NOT_STARTED
var elapsed_time: float = 0.0
var objectives: Array[Dictionary] = [] # {id, description, completed, progress, target}

signal mission_started
signal mission_completed(score: int)
signal mission_failed(reason: String)
signal objective_updated(objective_id: String, progress: float, target: float)
signal objective_completed(objective_id: String)

func _process(delta: float) -> void:
	if status == MissionStatus.IN_PROGRESS:
		update_mission(delta)

func start_mission() -> void:
	status = MissionStatus.IN_PROGRESS
	elapsed_time = 0.0
	mission_started.emit()

func update_mission(delta: float) -> void:
	elapsed_time += delta
	if time_limit > 0 and elapsed_time >= time_limit:
		fail_mission("Kehabisan waktu!")

func complete_mission() -> void:
	if status == MissionStatus.IN_PROGRESS:
		status = MissionStatus.COMPLETED
		mission_completed.emit(calculate_score())

func fail_mission(reason: String) -> void:
	if status == MissionStatus.IN_PROGRESS:
		status = MissionStatus.FAILED
		mission_failed.emit(reason)

func get_progress() -> float:
	return 0.0 # Virtual

func calculate_score() -> int:
	return 0 # Virtual
