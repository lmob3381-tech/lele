class_name WeaponBase extends Node3D

@export var weapon_name: String = "Weapon"
@export var damage: float = 10.0
@export var attack_speed: float = 1.0
@export var durability: float = 100.0
@export var max_durability: float = 100.0

var can_attack: bool = true
var attack_cooldown_timer: Timer

signal weapon_attacked()
signal weapon_broke()
signal durability_changed(current: float, max_val: float)

func _ready() -> void:
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_finished)
	add_child(attack_cooldown_timer)

func attack() -> bool:
	if not can_attack or durability <= 0:
		return false
		
	can_attack = false
	attack_cooldown_timer.start(1.0 / attack_speed)
	weapon_attacked.emit()
	return true

func _on_attack_cooldown_finished() -> void:
	can_attack = true

func reduce_durability(amount: float) -> void:
	durability -= amount
	durability = maxf(0.0, durability)
	durability_changed.emit(durability, max_durability)
	
	if durability <= 0.0:
		weapon_broke.emit()
