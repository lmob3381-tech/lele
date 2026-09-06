class_name ShieldAbility extends AbilityBase

@export var damage_reduction: float = 0.8

func _ready() -> void:
	ability_name = "Shield"
	cooldown_time = 45.0
	duration = 5.0
	description = "Reduces incoming damage by 80% for 5 seconds."

func activate() -> bool:
	if super.activate():
		# Apply visual effect and logical damage reduction here
		if owner and owner.has_method("set_damage_reduction"):
			owner.set_damage_reduction(damage_reduction)
		return true
	return false

func deactivate() -> void:
	super.deactivate()
	# Remove damage reduction
	if owner and owner.has_method("set_damage_reduction"):
		owner.set_damage_reduction(0.0)
