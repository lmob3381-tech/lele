extends Control

@onready var health_bar: ProgressBar = $TopLeft/HealthBar
@onready var objective_label: Label = $TopRight/ObjectiveLabel
@onready var objective_progress: Label = $TopRight/ObjectiveProgress
@onready var timer_label: Label = $TopCenter/TimerLabel
@onready var interaction_prompt: Label = $BottomCenter/InteractionPrompt
@onready var jumpscare_overlay: ColorRect = $JumpscareOverlay
@onready var weapon_info: Label = $BottomRight/WeaponInfo
@onready var weapon_durability: ProgressBar = $BottomRight/WeaponDurability
@onready var ability_info: Label = $BottomRight/AbilityInfo
@onready var extraction_bar: ProgressBar = $BottomCenter/ExtractionBar

var jumpscare_timer: Timer

func _ready() -> void:
	jumpscare_timer = Timer.new()
	jumpscare_timer.one_shot = true
	jumpscare_timer.timeout.connect(_on_jumpscare_timeout)
	add_child(jumpscare_timer)

func update_health(current: float, max_val: float) -> void:
	health_bar.max_value = max_val
	health_bar.value = current

func update_mission_objective(text: String, progress: String) -> void:
	objective_label.text = "Objective: " + text
	objective_progress.text = progress

func update_timer(time_remaining: float) -> void:
	var mins = int(time_remaining) / 60
	var secs = int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

func show_interaction_prompt(text: String) -> void:
	if text.is_empty():
		interaction_prompt.hide()
	else:
		interaction_prompt.text = text
		interaction_prompt.show()

func trigger_jumpscare_overlay(duration: float, intensity: float) -> void:
	jumpscare_overlay.color = Color(0, 0, 0, intensity)
	jumpscare_overlay.show()
	jumpscare_timer.wait_time = duration
	jumpscare_timer.start()

func _on_jumpscare_timeout() -> void:
	jumpscare_overlay.hide()

func update_weapon_info(w_name: String, durability: float, max_durability: float) -> void:
	weapon_info.text = "Weapon: " + w_name
	weapon_durability.max_value = max_durability
	weapon_durability.value = durability

func update_ability_info(a_name: String, cooldown_remaining: float, cooldown_total: float) -> void:
	if cooldown_remaining <= 0:
		ability_info.text = "Ability: " + a_name + " (Ready)"
	else:
		ability_info.text = "Ability: " + a_name + " (%.1fs)" % cooldown_remaining

func show_status_effect(effect_name: String, duration: float) -> void:
	# Add icon to TopLeft/StatusEffects
	pass

func show_extraction_progress(progress: float) -> void:
	if progress > 0:
		extraction_bar.show()
		extraction_bar.value = progress * 100.0
	else:
		extraction_bar.hide()
