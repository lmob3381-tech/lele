class_name RadarAbility extends AbilityBase

@export var detection_range: float = 30.0

signal entities_detected(positions: Array[Vector3])

func _ready() -> void:
	ability_name = "Radar"
	cooldown_time = 60.0
	duration = 10.0
	description = "Detect nearby horror entities for 10 seconds."

func activate() -> bool:
	if super.activate():
		# In a real scenario, this would query a group or physics server
		var entities: Array[Node] = get_tree().get_nodes_in_group("horror_entities")
		var detected_positions: Array[Vector3] = []
		
		for entity: Node3D in entities:
			if owner and entity.global_position.distance_to(owner.global_position) <= detection_range:
				detected_positions.append(entity.global_position)
				
		entities_detected.emit(detected_positions)
		return true
	return false

func deactivate() -> void:
	super.deactivate()
