extends Area3D
class_name HorrorTriggerZone

# Invisible trigger zones placed in the map
@export_enum("spawn", "jumpscare", "ambient") var trigger_type: String = "spawn"
@export var one_shot: bool = true
@export var spawn_probability: float = 0.5
@export var jumpscare_intensity: float = 0.7

var has_triggered: bool = false

signal zone_triggered(type: String, trigger_position: Vector3)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if has_triggered and one_shot:
		return
		
	if body.is_in_group("players"):
		if randf() <= spawn_probability:
			_execute_trigger()

func _execute_trigger() -> void:
	if one_shot:
		has_triggered = true
		
	zone_triggered.emit(trigger_type, global_position)
	
	match trigger_type:
		"spawn":
			# Handled by HorrorSpawner connected to this signal
			pass
		"jumpscare":
			var jumpscare_sys = get_tree().get_first_node_in_group("jumpscare_system")
			if jumpscare_sys and jumpscare_sys.has_method("trigger_jumpscare"):
				jumpscare_sys.trigger_jumpscare(jumpscare_intensity, "both")
		"ambient":
			var jumpscare_sys = get_tree().get_first_node_in_group("jumpscare_system")
			if jumpscare_sys and jumpscare_sys.has_method("trigger_jumpscare"):
				jumpscare_sys.trigger_jumpscare(jumpscare_intensity, "ambient")
