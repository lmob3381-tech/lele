class_name PlayerController extends CharacterBody3D

@export var move_speed: float = 4.0
@export var sprint_speed: float = 6.5
@export var crouch_speed: float = 2.0
@export var gravity: float = 20.0
@export var jump_force: float = 0.0

var is_sprinting: bool = false
var is_crouching: bool = false
var input_direction: Vector2 = Vector2.ZERO
var camera_rotation: Vector2 = Vector2.ZERO

@onready var camera_pivot: Node3D = $CameraPivot if has_node("CameraPivot") else self
@onready var interaction_ray: RayCast3D = $CameraPivot/InteractionRay if has_node("CameraPivot/InteractionRay") else null

var slow_multiplier: float = 1.0

signal interacted_with(object: Node)
signal took_damage(amount: float)
signal died()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var current_speed: float = move_speed
	if is_sprinting and not is_crouching:
		current_speed = sprint_speed
	elif is_crouching:
		current_speed = crouch_speed
		
	current_speed *= slow_multiplier

	# Movement direction relative to camera rotation
	var direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	
	if is_multiplayer_authority():
		_sync_position.rpc(global_position, rotation)

@rpc("unreliable", "call_local", "any_peer")
func _sync_position(pos: Vector3, rot: Vector3) -> void:
	if not is_multiplayer_authority():
		global_position = pos
		rotation = rot

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()
	
	if event is InputEventKey:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		input_direction = input_dir
		
		if event.is_action_pressed("sprint"):
			is_sprinting = true
		elif event.is_action_released("sprint"):
			is_sprinting = false
			
		if event.is_action_pressed("crouch"):
			is_crouching = true
		elif event.is_action_released("crouch"):
			is_crouching = false

func _try_interact() -> void:
	if interaction_ray and interaction_ray.is_colliding():
		var target := interaction_ray.get_collider()
		if target and target.has_method("interact"):
			target.interact(self)
			interacted_with.emit(target)
