class_name PlayerCamera extends Node3D

@export var follow_speed: float = 10.0
@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -60.0
@export var max_pitch: float = 60.0
@export var camera_distance: float = 3.0

var _yaw: float = 0.0
var _pitch: float = 0.0

@onready var spring_arm: SpringArm3D = $SpringArm3D if has_node("SpringArm3D") else null
@onready var camera: Camera3D = $SpringArm3D/Camera3D if has_node("SpringArm3D/Camera3D") else null

var invert_camera_y: bool = false

func _ready() -> void:
	if spring_arm:
		spring_arm.spring_length = camera_distance
		
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		# Assuming right side of screen is for camera
		if event.position.x > get_viewport().get_visible_rect().size.x / 2:
			_yaw -= event.relative.x * mouse_sensitivity
			
			var pitch_change: float = event.relative.y * mouse_sensitivity
			if invert_camera_y:
				_pitch += pitch_change
			else:
				_pitch -= pitch_change
				
			_pitch = clamp(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, _yaw, follow_speed * delta)
	if spring_arm:
		spring_arm.rotation.x = lerp_angle(spring_arm.rotation.x, _pitch, follow_speed * delta)
