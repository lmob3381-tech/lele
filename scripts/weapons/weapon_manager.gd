class_name WeaponManager extends Node

var weapons: Array[WeaponBase] = []
var current_weapon_index: int = -1

var current_weapon: WeaponBase:
	get:
		if current_weapon_index >= 0 and current_weapon_index < weapons.size():
			return weapons[current_weapon_index]
		return null

signal weapon_switched(weapon: WeaponBase)
signal weapon_equipped(weapon: WeaponBase)
signal weapon_dropped()

func equip_weapon(weapon: WeaponBase) -> void:
	weapons.append(weapon)
	weapon_equipped.emit(weapon)
	if weapons.size() == 1:
		switch_weapon(0)

func switch_weapon(index: int) -> void:
	if index >= 0 and index < weapons.size():
		current_weapon_index = index
		weapon_switched.emit(current_weapon)

func attack() -> void:
	if current_weapon:
		current_weapon.attack()

func drop_weapon() -> void:
	if current_weapon:
		weapons.remove_at(current_weapon_index)
		weapon_dropped.emit()
		current_weapon_index = -1
		if weapons.size() > 0:
			switch_weapon(0)
