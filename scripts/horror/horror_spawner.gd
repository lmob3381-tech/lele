extends Node3D
class_name HorrorSpawner

# Controls when and where pocong entities appear
@export var min_spawn_interval: float = 30.0
@export var max_spawn_interval: float = 90.0
@export var max_active_pocong: int = 3
@export var spawn_probability_base: float = 0.3 # 30% chance per check
@export var probability_increase_per_minute: float = 0.05

var spawn_points: Array[Vector3] = []
var active_pocong_count: int = 0
var elapsed_time: float = 0.0
var spawn_timer: Timer

signal pocong_spawned(position: Vector3)
signal intensity_increased

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Collect spawn points from child Marker3Ds
	for child in get_children():
		if child is Marker3D:
			spawn_points.append(child.global_position)
			
	_reset_timer()

func _process(delta: float) -> void:
	elapsed_time += delta
	if int(elapsed_time) % 60 == 0 and elapsed_time > 0:
		intensity_increased.emit()

func _reset_timer() -> void:
	spawn_timer.start(randf_range(min_spawn_interval, max_spawn_interval))

func _on_spawn_timer_timeout() -> void:
	if active_pocong_count >= max_active_pocong or spawn_points.is_empty():
		_reset_timer()
		return
		
	var minutes_passed = int(elapsed_time / 60.0)
	var current_prob = spawn_probability_base + (probability_increase_per_minute * minutes_passed)
	
	if randf() <= current_prob:
		var pos = _get_valid_spawn_point()
		if pos != Vector3.INF:
			spawn_pocong(pos)
			
	_reset_timer()

func _get_valid_spawn_point() -> Vector3:
	var valid_points = spawn_points.duplicate()
	valid_points.shuffle()
	
	var players = get_tree().get_nodes_in_group("players")
	for pt in valid_points:
		var is_valid = true
		for p in players:
			if p is Node3D and pt.distance_to(p.global_position) < 20.0:
				is_valid = false
				break
		if is_valid:
			return pt
			
	return Vector3.INF

func spawn_pocong(spawn_pos: Vector3) -> void:
	if active_pocong_count >= max_active_pocong: return
	
	# Placeholder for pooling instantiation
	# var pocong = object_pool.acquire("pocong")
	# pocong.global_position = spawn_pos
	# pocong.despawned.connect(_on_pocong_despawned)
	
	active_pocong_count += 1
	pocong_spawned.emit(spawn_pos)

func _on_pocong_despawned() -> void:
	active_pocong_count = max(0, active_pocong_count - 1)
