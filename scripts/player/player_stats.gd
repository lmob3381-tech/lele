class_name PlayerStats extends Node

@export var max_health: float = 100.0
var current_health: float
var is_alive: bool = true
var status_effects: Dictionary = {}

signal health_changed(new_health: float, max_health: float)
signal player_died()
signal status_effect_applied(effect_name: String)
signal status_effect_removed(effect_name: String)

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float, source: String = "") -> void:
	if not is_alive:
		return
		
	current_health -= amount
	current_health = maxf(0.0, current_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0.0:
		is_alive = false
		player_died.emit()

func heal(amount: float) -> void:
	if not is_alive:
		return
		
	current_health += amount
	current_health = minf(max_health, current_health)
	health_changed.emit(current_health, max_health)

func apply_status_effect(effect: String, duration: float, strength: float) -> void:
	status_effects[effect] = {"duration": duration, "strength": strength}
	status_effect_applied.emit(effect)

func remove_status_effect(effect: String) -> void:
	if status_effects.has(effect):
		status_effects.erase(effect)
		status_effect_removed.emit(effect)

func _process(delta: float) -> void:
	_process_status_effects(delta)

func _process_status_effects(delta: float) -> void:
	var effects_to_remove: Array[String] = []
	
	for effect: String in status_effects.keys():
		status_effects[effect].duration -= delta
		if status_effects[effect].duration <= 0:
			effects_to_remove.append(effect)
			
	for effect: String in effects_to_remove:
		remove_status_effect(effect)
