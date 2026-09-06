extends Node
class_name ServerMain

const PORT: int = 10402
const MAX_CLIENTS: int = 100

var peer: ENetMultiplayerPeer
var connected_players: Dictionary = {} # id -> data

func _ready() -> void:
	print("[Server] Initializing Dedicated Server...")
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_CLIENTS)
	if err != OK:
		print("[Server] FAILED to start server on port ", PORT, ". Error: ", err)
		return
		
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	print("[Server] Successfully started on port ", PORT)
	print("[Server] Waiting for players...")

func _on_peer_connected(id: int) -> void:
	print("[Server] Client connected: ", id)
	connected_players[id] = {
		"id": id,
		"state": "CONNECTED"
	}
	# Send handshake info to client
	rpc_id(id, "receive_server_info", {
		"protocol_version": 1,
		"server_version": "0.1.0",
		"server_name": "Malam Terakhir Official",
		"max_players": MAX_CLIENTS,
		"current_players": connected_players.size()
	})

func _on_peer_disconnected(id: int) -> void:
	print("[Server] Client disconnected: ", id)
	if connected_players.has(id):
		connected_players.erase(id)
	
	if has_node("MatchManager"):
		get_node("MatchManager").handle_player_disconnect(id)

@rpc("any_peer", "call_remote", "reliable")
func authenticate(client_protocol: int) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	print("[Server] Auth request from ", sender_id, " protocol: ", client_protocol)
	
	if client_protocol != 1:
		print("[Server] Rejecting ", sender_id, ": Incompatible protocol")
		rpc_id(sender_id, "auth_rejected", "Incompatible version. Client: " + str(client_protocol) + ", Server: 1")
		multiplayer.disconnect_peer(sender_id)
		return
		
	print("[Server] Accepted ", sender_id)
	connected_players[sender_id]["state"] = "LOBBY"
	rpc_id(sender_id, "auth_accepted")

# Dummy client RPCs for validation
@rpc("authority", "call_remote", "reliable")
func receive_server_info(info: Dictionary) -> void: pass
@rpc("authority", "call_remote", "reliable")
func auth_rejected(reason: String) -> void: pass
@rpc("authority", "call_remote", "reliable")
func auth_accepted() -> void: pass
