extends Area3D
class_name Interactable

# Base class for interactive objects in the world
@export var interaction_name: String = "Interact"
@export var interaction_prompt: String = "Press E to interact"
@export var one_shot: bool = false
@export var interaction_time: float = 0.0 # instant if 0

var has_interacted: bool = false
var is_player_nearby: bool = false

signal interacted(player: Node3D)
signal interaction_started(player: Node3D)
signal interaction_cancelled

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func interact(player: Node3D) -> bool:
	if has_interacted and one_shot:
		return false
		
	if interaction_time > 0.0:
		interaction_started.emit(player)
		# A real implementation would handle hold-to-interact via player script 
		# or a coroutine that can be cancelled. For now, assume it succeeds.
		
	_perform_interaction(player)
	return true

func _perform_interaction(player: Node3D) -> void:
	if one_shot:
		has_interacted = true
		
	interacted.emit(player)
	
	# Override this in child classes (Door, Collectible, Switch, etc)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		is_player_nearby = true
		if not (one_shot and has_interacted):
			# Show UI prompt placeholder
			pass

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		is_player_nearby = false
		interaction_cancelled.emit()
		# Hide UI prompt placeholder
		pass
