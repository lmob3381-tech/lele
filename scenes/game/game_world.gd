extends Node3D

@export var player_scene: PackedScene

@onready var spawn_points: Node3D = $SpawnPoints
@onready var hud: Control = $HUDLayer/HUD
@onready var extraction_point: Area3D = $ExtractionPoint

var mission_data: Dictionary = {}
var game_active: bool = false
var time_survived: float = 0.0

func _ready() -> void:
	if multiplayer.is_server():
		var peers = multiplayer.get_peers()
		spawn_player(multiplayer.get_unique_id(), 0)
		var index = 1
		for peer in peers:
			spawn_player(peer, index)
			index += 1
			
	extraction_point.body_entered.connect(_on_extraction_entered)
	setup_mission({"type": "survive", "duration": 300})
	game_active = true

func _process(delta: float) -> void:
	if game_active:
		time_survived += delta
		if mission_data.get("type") == "survive":
			var remaining = max(0, mission_data.get("duration", 300) - time_survived)
			hud.update_timer(remaining)
			if remaining <= 0:
				_on_mission_completed(1000)

func spawn_player(peer_id: int, spawn_index: int) -> void:
	if not player_scene:
		return
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	
	var spawns = spawn_points.get_children()
	if spawns.size() > 0:
		var spawn_pos = spawns[spawn_index % spawns.size()].global_position
		player.global_position = spawn_pos
		
	add_child(player)

func setup_mission(data: Dictionary) -> void:
	mission_data = data
	if data.get("type") == "survive":
		hud.update_mission_objective("Survive", "")

func _on_extraction_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.name == str(multiplayer.get_unique_id()):
		_on_mission_completed(500)

func _on_mission_completed(score: int) -> void:
	game_active = false
	if not GlobalData:
		var gd = Node.new()
		gd.name = "GlobalData"
		get_tree().root.add_child(gd)
		
	# Store result globally
	if get_tree().root.has_node("GlobalData"):
		get_tree().root.get_node("GlobalData").set("mission_result", {
			"success": true,
			"time_survived": time_survived,
			"score": score
		})
		
	if has_node("/root/SceneManager"):
		get_node("/root/SceneManager").change_scene(get_node("/root/SceneManager").EXTRACTION)
	else:
		get_tree().change_scene_to_file("res://scenes/extraction/extraction.tscn")

func _on_mission_failed(reason: String) -> void:
	game_active = false
	if get_tree().root.has_node("GlobalData"):
		get_tree().root.get_node("GlobalData").set("mission_result", {
			"success": false,
			"time_survived": time_survived,
			"score": 0
		})
	
	if has_node("/root/SceneManager"):
		get_node("/root/SceneManager").change_scene(get_node("/root/SceneManager").EXTRACTION)
	else:
		get_tree().change_scene_to_file("res://scenes/extraction/extraction.tscn")
