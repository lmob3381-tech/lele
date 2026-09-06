class_name TouchControls extends CanvasLayer

@export var joystick_radius: float = 100.0

var movement_vector: Vector2 = Vector2.ZERO
var camera_delta: Vector2 = Vector2.ZERO

signal joystick_input(direction: Vector2)
signal camera_input(delta: Vector2)
signal attack_pressed()
signal interact_pressed()
signal ability_pressed()
signal sprint_toggled(is_sprinting: bool)
signal crouch_toggled(is_crouching: bool)

var _is_sprinting: bool = false
var _is_crouching: bool = false

func _ready() -> void:
	if OS.get_name() in ["Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]:
		hide()
	else:
		show()

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	# Placeholder for actual touch control logic
	pass

func _on_attack_button_pressed() -> void:
	attack_pressed.emit()

func _on_interact_button_pressed() -> void:
	interact_pressed.emit()

func _on_ability_button_pressed() -> void:
	ability_pressed.emit()

func _on_sprint_button_toggled(button_pressed: bool) -> void:
	_is_sprinting = button_pressed
	sprint_toggled.emit(_is_sprinting)

func _on_crouch_button_toggled(button_pressed: bool) -> void:
	_is_crouching = button_pressed
	crouch_toggled.emit(_is_crouching)
