class_name AbilityManager extends Node

var abilities: Array[AbilityBase] = []
var active_ability_index: int = 0

signal ability_used(ability: AbilityBase)
signal ability_switched(ability: AbilityBase)

func use_ability() -> void:
	if abilities.is_empty() or active_ability_index < 0 or active_ability_index >= abilities.size():
		return
		
	var ability: AbilityBase = abilities[active_ability_index]
	if ability.activate():
		ability_used.emit(ability)

func switch_ability(index: int) -> void:
	if index >= 0 and index < abilities.size():
		active_ability_index = index
		ability_switched.emit(abilities[active_ability_index])
