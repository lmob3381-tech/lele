class_name AbilityBase extends Node

@export var ability_name: String = "Ability"
@export var cooldown_time: float = 30.0
@export var duration: float = 5.0
@export var description: String = ""

var is_on_cooldown: bool = false
var is_active: bool = false
var cooldown_remaining: float = 0.0
var duration_remaining: float = 0.0

signal ability_activated()
signal ability_deactivated()
signal cooldown_updated(remaining: float, total: float)

func activate() -> bool:
	if is_on_cooldown or is_active:
		return false
	
	is_active = true
	duration_remaining = duration
	ability_activated.emit()
	return true

func deactivate() -> void:
	if not is_active:
		return
		
	is_active = false
	is_on_cooldown = true
	cooldown_remaining = cooldown_time
	ability_deactivated.emit()

func _process(delta: float) -> void:
	if is_active:
		duration_remaining -= delta
		if duration_remaining <= 0.0:
			deactivate()
			
	if is_on_cooldown:
		cooldown_remaining -= delta
		cooldown_updated.emit(cooldown_remaining, cooldown_time)
		if cooldown_remaining <= 0.0:
			is_on_cooldown = false
			cooldown_remaining = 0.0
