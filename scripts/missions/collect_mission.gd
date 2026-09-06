extends MissionBase
class_name CollectMission

# Collect ritual objects scattered in the map
@export var items_to_collect: int = 5
@export var item_scene: PackedScene

var items_collected: int = 0
var collectible_positions: Array[Vector3] = []

func _ready() -> void:
	# Adjust difficulty
	match difficulty:
		1: items_to_collect = 5
		2: items_to_collect = 7
		3, 4, 5: items_to_collect = 10
	
	objectives.append({
		"id": "collect_items",
		"description": "Kumpulkan objek ritual",
		"completed": false,
		"progress": 0.0,
		"target": items_to_collect
	})

func start_mission() -> void:
	super.start_mission()
	# Spawn collectibles logic placeholder
	# for i in items_to_collect: spawn item_scene at random map points

func on_item_collected(item_id: String) -> void:
	if status != MissionStatus.IN_PROGRESS: return
	
	items_collected += 1
	
	for obj in objectives:
		if obj["id"] == "collect_items":
			obj["progress"] = items_collected
			objective_updated.emit(obj["id"], obj["progress"], obj["target"])
			if items_collected >= obj["target"] and not obj["completed"]:
				obj["completed"] = true
				objective_completed.emit(obj["id"])
				
	if items_collected >= items_to_collect:
		complete_mission()

func update_mission(delta: float) -> void:
	super.update_mission(delta) # Handles time limit

func get_progress() -> float:
	return float(items_collected) / float(items_to_collect)

func calculate_score() -> int:
	var base_score = 1000
	var time_remaining = max(0.0, time_limit - elapsed_time)
	var time_bonus = (time_remaining / time_limit)
	return int(base_score * (1.0 + time_bonus) * difficulty)
