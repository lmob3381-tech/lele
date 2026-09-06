extends Area3D
class_name ExtractionPoint

# Extraction zone where players go to finish mission
@export var extraction_time: float = 5.0 # hold position for 5 sec
@export var is_active: bool = false

var players_in_zone: Array[CharacterBody3D] = []
var extraction_progress: float = 0.0

signal extraction_started
signal extraction_progress_updated(progress: float)
signal extraction_completed
signal extraction_cancelled

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if not is_active: return
	
	if not players_in_zone.is_empty():
		if extraction_progress == 0.0:
			extraction_started.emit()
			
		extraction_progress += delta
		extraction_progress_updated.emit(extraction_progress / extraction_time)
		
		if extraction_progress >= extraction_time:
			is_active = false
			extraction_completed.emit()
	else:
		if extraction_progress > 0.0:
			extraction_progress -= delta * 2.0 # Decay fast when out of zone
			if extraction_progress <= 0.0:
				extraction_progress = 0.0
				extraction_cancelled.emit()
		extraction_progress_updated.emit(extraction_progress / extraction_time)

func activate() -> void:
	is_active = true
	# Show visual indicator here (pulsing light, etc)
	show()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("players") and body is CharacterBody3D:
		if not players_in_zone.has(body):
			players_in_zone.append(body)

func _on_body_exited(body: Node3D) -> void:
	if body in players_in_zone:
		players_in_zone.erase(body)
