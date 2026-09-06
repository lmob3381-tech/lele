extends Node
class_name DatabaseManager

const DB_FILE = "user://players.json"
var player_data: Dictionary = {}

func _ready() -> void:
	_load_db()

func _load_db() -> void:
	if FileAccess.file_exists(DB_FILE):
		var file = FileAccess.open(DB_FILE, FileAccess.READ)
		var content = file.get_as_text()
		var json = JSON.new()
		if json.parse(content) == OK:
			player_data = json.data
			print("[DB] Loaded player data for ", player_data.size(), " players.")
		file.close()
	else:
		print("[DB] No DB file found. Creating new.")
		_save_db()

func _save_db() -> void:
	var file = FileAccess.open(DB_FILE, FileAccess.WRITE)
	var content = JSON.stringify(player_data, "\t")
	file.store_string(content)
	file.close()

func add_reward(player_uuid: String, score: int) -> void:
	if not player_data.has(player_uuid):
		player_data[player_uuid] = {"score": 0, "matches_played": 0}
		
	player_data[player_uuid]["score"] += score
	player_data[player_uuid]["matches_played"] += 1
	_save_db()
	print("[DB] Updated score for ", player_uuid, " -> ", player_data[player_uuid]["score"])
