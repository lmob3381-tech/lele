extends Node
class_name MissionManager

# Manages mission lifecycle
var current_mission: MissionBase = null
var available_missions: Array[Dictionary] = [
	{"name": "Kumpulkan Ritual", "type": "collect", "difficulty": 1},
	{"name": "Bertahan Hidup", "type": "survive", "difficulty": 2}
]

signal mission_selected(mission_data: Dictionary)
signal mission_started
signal mission_ended(success: bool, score: int)

func select_mission(mission_data: Dictionary) -> void:
	if is_instance_valid(current_mission):
		current_mission.queue_free()
		
	var mission_script: Script
	match mission_data["type"]:
		"collect":
			mission_script = load("res://scripts/missions/collect_mission.gd")
		"survive":
			mission_script = load("res://scripts/missions/survive_mission.gd")
			
	if mission_script:
		var mission = mission_script.new()
		mission.mission_name = mission_data["name"]
		mission.difficulty = mission_data["difficulty"]
		add_child(mission)
		current_mission = mission
		
		# Connect signals
		current_mission.mission_completed.connect(_on_mission_completed)
		current_mission.mission_failed.connect(_on_mission_failed)
		
		mission_selected.emit(mission_data)

func start_current_mission() -> void:
	if is_instance_valid(current_mission):
		current_mission.start_mission()
		mission_started.emit()

func _on_mission_completed(score: int) -> void:
	# Validation logic placeholder for server
	mission_ended.emit(true, score)
	_grant_rewards(score)

func _on_mission_failed(reason: String) -> void:
	mission_ended.emit(false, 0)

func get_available_missions() -> Array[Dictionary]:
	return available_missions

func _grant_rewards(score: int) -> void:
	# Add XP/Coins based on score
	pass
