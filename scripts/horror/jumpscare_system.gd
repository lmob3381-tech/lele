extends Node
class_name JumpscareSystem

# Manages jumpscare visual and audio effects
signal jumpscare_triggered(intensity: float)

var is_jumpscare_active: bool = false
var last_jumpscare_time: float = -10.0
const MIN_COOLDOWN: float = 10.0

@onready var visual_overlay: ColorRect # Placeholder for injected UI node

func _ready() -> void:
	pass

func trigger_jumpscare(intensity: float = 1.0, type: String = "visual") -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if is_jumpscare_active or (current_time - last_jumpscare_time) < MIN_COOLDOWN:
		return
		
	is_jumpscare_active = true
	last_jumpscare_time = current_time
	jumpscare_triggered.emit(intensity)
	
	var duration: float = clamp(0.5 * intensity, 0.5, 1.5)
	
	match type:
		"visual":
			_play_visual_scare(duration)
		"audio":
			_play_audio_scare(intensity)
		"both":
			_play_visual_scare(duration)
			_play_audio_scare(intensity)
		"ambient":
			_play_ambient_scare()

func _play_visual_scare(duration: float) -> void:
	if not is_instance_valid(visual_overlay):
		await get_tree().create_timer(duration).timeout
		_on_jumpscare_finished()
		return
		
	visual_overlay.show()
	visual_overlay.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(visual_overlay, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_on_jumpscare_finished)
	
	# Add camera shake here

func _play_audio_scare(intensity: float) -> void:
	# Audio stream play placeholder
	if not is_jumpscare_active: # If only audio was requested
		await get_tree().create_timer(1.0).timeout
		_on_jumpscare_finished()

func _play_ambient_scare() -> void:
	# Lights flicker, whisper sounds
	await get_tree().create_timer(2.0).timeout
	_on_jumpscare_finished()

func _on_jumpscare_finished() -> void:
	is_jumpscare_active = false
	if is_instance_valid(visual_overlay):
		visual_overlay.hide()
