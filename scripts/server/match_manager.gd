extends Node
class_name MatchManager

# room_id -> { host_id, players, status, mission_type }
var active_rooms: Dictionary = {}

func create_room(host_id: int) -> String:
	var room_code = _generate_room_code()
	active_rooms[room_code] = {
		"host_id": host_id,
		"players": [host_id],
		"status": "WAITING",
		"mission_type": "none"
	}
	print("[Match] Room created: ", room_code, " by ", host_id)
	return room_code

func join_room(player_id: int, room_code: String) -> bool:
	if active_rooms.has(room_code) and active_rooms[room_code].status == "WAITING":
		if active_rooms[room_code].players.size() < 4:
			active_rooms[room_code].players.append(player_id)
			print("[Match] Player ", player_id, " joined room ", room_code)
			return true
	return false

func handle_player_disconnect(player_id: int) -> void:
	for room_code in active_rooms.keys():
		var room = active_rooms[room_code]
		if player_id in room.players:
			room.players.erase(player_id)
			if room.players.is_empty():
				active_rooms.erase(room_code)
				print("[Match] Room ", room_code, " closed (empty)")
			elif room.host_id == player_id:
				room.host_id = room.players[0] # Transfer host
				print("[Match] Room ", room_code, " host transferred to ", room.host_id)

func _generate_room_code() -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	for i in range(5):
		code += chars[randi() % chars.length()]
	return code

# --- RPC Definitions (Authoritative server validation) ---

@rpc("any_peer", "call_remote", "reliable")
func req_create_room() -> void:
	var sender = multiplayer.get_remote_sender_id()
	var code = create_room(sender)
	rpc_id(sender, "res_room_created", code)

@rpc("any_peer", "call_remote", "reliable")
func req_join_room(code: String) -> void:
	var sender = multiplayer.get_remote_sender_id()
	var success = join_room(sender, code)
	rpc_id(sender, "res_join_room", success)

# Client RPC signatures
@rpc("authority", "call_remote", "reliable")
func res_room_created(code: String) -> void: pass
@rpc("authority", "call_remote", "reliable")
func res_join_room(success: bool) -> void: pass
