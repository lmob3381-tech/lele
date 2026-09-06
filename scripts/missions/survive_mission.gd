extends MissionBase
class_name SurviveMission

# Survive for a set duration against waves of pocong
@export var survive_duration: float = 180.0 # 3 minutes
@export var wave_interval: float = 30.0
@export var pocong_per_wave_base: int = 1

var waves_survived: int = 0
var wave_timer: float = 0.0
var all_players_alive: bool = true

func _ready() -> void:
	# Adjust difficulty
	time_limit = survive_duration
	match difficulty:
		1: pocong_per_wave_base = 1
		2: pocong_per_wave_base = 2
		3, 4, 5: pocong_per_wave_base = 3
	
	objectives.append({
		"id": "survive_time",
		"description": "Bertahan hidup",
		"completed": false,
		"progress": 0.0,
		"target": survive_duration
	})

func start_mission() -> void:
	super.start_mission()
	wave_timer = wave_interval # Trigger first wave soon

func update_mission(delta: float) -> void:
	if status != MissionStatus.IN_PROGRESS: return
	
	elapsed_time += delta
	wave_timer -= delta
	
	for obj in objectives:
		if obj["id"] == "survive_time":
			obj["progress"] = elapsed_time
			objective_updated.emit(obj["id"], obj["progress"], obj["target"])
	
	if wave_timer <= 0.0:
		_spawn_wave(waves_survived + 1)
		waves_survived += 1
		wave_timer = wave_interval
		
	if elapsed_time >= survive_duration:
		complete_mission()

func _spawn_wave(wave_number: int) -> void:
	var count = pocong_per_wave_base + (wave_number / 2)
	# Trigger spawner placeholder
	# horror_spawner.spawn_multiple(count)

func on_player_died() -> void:
	# Check if all players dead
	var players = get_tree().get_nodes_in_group("players")
	all_players_alive = false
	for p in players:
		if p.has_method("is_alive") and p.is_alive():
			all_players_alive = true
			break
			
	if not all_players_alive:
		fail_mission("Seluruh tim telah gugur!")

func get_progress() -> float:
	return min(1.0, elapsed_time / survive_duration)

func calculate_score() -> int:
	var base = 500
	return int(base * (waves_survived + 1) * difficulty)
