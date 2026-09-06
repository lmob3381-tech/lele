extends CharacterBody3D
class_name PocongEntity

# Entitas horor utama - hantu pocong
enum PocongState {IDLE, PATROL, LURK, CHASE, ATTACK, RETREAT, DESPAWN}

@export var move_speed: float = 3.0
@export var chase_speed: float = 5.5
@export var detection_range: float = 15.0
@export var attack_range: float = 2.0
@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 3.0

var current_state: PocongState = PocongState.IDLE
var target_player: CharacterBody3D = null
var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0
var attack_timer: float = 0.0

signal player_attacked(player: CharacterBody3D, damage: float)
signal despawned

@onready var navigation_agent: NavigationAgent3D = NavigationAgent3D.new()

func _ready() -> void:
	add_child(navigation_agent)

func _physics_process(delta: float) -> void:
	if attack_timer > 0:
		attack_timer -= delta
		
	match current_state:
		PocongState.IDLE:
			_process_idle(delta)
		PocongState.PATROL:
			_process_patrol(delta)
		PocongState.LURK:
			_process_lurk(delta)
		PocongState.CHASE:
			_process_chase(delta)
		PocongState.ATTACK:
			_process_attack(delta)
		PocongState.RETREAT:
			_process_retreat(delta)
		PocongState.DESPAWN:
			_process_despawn(delta)

func _process_idle(_delta: float) -> void:
	_detect_players()
	if target_player:
		current_state = PocongState.CHASE

func _process_patrol(_delta: float) -> void:
	_detect_players()
	if target_player:
		current_state = PocongState.CHASE
		return
	if patrol_points.is_empty():
		return
		
	var target = patrol_points[current_patrol_index]
	var dir = (target - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()
	if global_position.distance_to(target) < 1.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func _process_lurk(_delta: float) -> void:
	_detect_players()
	if target_player and global_position.distance_to(target_player.global_position) < detection_range * 0.5:
		current_state = PocongState.CHASE

func _process_chase(_delta: float) -> void:
	if not is_instance_valid(target_player):
		current_state = PocongState.IDLE
		return
		
	var dist = global_position.distance_to(target_player.global_position)
	if dist <= attack_range:
		current_state = PocongState.ATTACK
		return
	elif dist > detection_range * 2.0:
		target_player = null
		current_state = PocongState.RETREAT
		return
		
	navigation_agent.target_position = target_player.global_position
	var next_pos = navigation_agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	velocity = dir * chase_speed
	move_and_slide()

func _process_attack(_delta: float) -> void:
	if not is_instance_valid(target_player) or global_position.distance_to(target_player.global_position) > attack_range:
		current_state = PocongState.CHASE
		return
		
	if attack_timer <= 0.0:
		_attack_player(target_player)
		attack_timer = attack_cooldown
		current_state = PocongState.RETREAT

func _process_retreat(_delta: float) -> void:
	# Teleport/fade logic here
	on_pool_recycle()

func _process_despawn(_delta: float) -> void:
	on_pool_recycle()

func _detect_players() -> void:
	# Dummy implementation - in a real game we check player group or Area3D
	var players = get_tree().get_nodes_in_group("players")
	var closest_player: CharacterBody3D = null
	var min_dist: float = detection_range
	for p in players:
		if p is CharacterBody3D:
			var d = global_position.distance_to(p.global_position)
			if d < min_dist:
				min_dist = d
				closest_player = p
	target_player = closest_player

func _attack_player(player: CharacterBody3D) -> void:
	player_attacked.emit(player, attack_damage)
	# Trigger jumpscare and status effects via signal or global manager

func on_pool_spawn() -> void:
	set_physics_process(true)
	current_state = PocongState.IDLE
	show()

func on_pool_recycle() -> void:
	set_physics_process(false)
	hide()
	despawned.emit()
