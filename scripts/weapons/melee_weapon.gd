class_name MeleeWeapon extends WeaponBase

@export var attack_range: float = 2.0
@export var attack_angle: float = 90.0
@export_enum("linggis", "golok") var weapon_type: String = "linggis"

var attack_area: Area3D

func _ready() -> void:
	super._ready()
	
	if weapon_type == "linggis":
		damage = 15.0
		attack_speed = 0.8
		max_durability = 150.0
	elif weapon_type == "golok":
		damage = 10.0
		attack_speed = 1.5
		max_durability = 80.0
		
	durability = max_durability
	
	attack_area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(attack_range, 1.0, attack_range)
	collision_shape.shape = box_shape
	collision_shape.position = Vector3(0, 0, -attack_range/2)
	attack_area.add_child(collision_shape)
	add_child(attack_area)
	
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)

func attack() -> bool:
	if super.attack():
		attack_area.monitoring = true
		get_tree().create_timer(0.2).timeout.connect(func(): attack_area.monitoring = false)
		return true
	return false

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage") and body != owner:
		if is_multiplayer_authority():
			_apply_damage.rpc_id(1, body.get_path(), damage)
		reduce_durability(1.0)

@rpc("any_peer", "call_remote", "reliable")
func _apply_damage(target_path: NodePath, dmg: float) -> void:
	var target = get_node_or_null(target_path)
	if target and target.has_method("take_damage"):
		target.take_damage(dmg)
