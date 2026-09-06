extends Node

## Singleton for multiplayer networking using ENet

const DEFAULT_PORT: int = 10403
const MAX_CLIENTS: int = 4
const CONNECTION_TIMEOUT: float = 12.0
const MAX_RECONNECT_ATTEMPTS: int = 3
const LAST_SERVER_FILE: String = "user://last_server.cfg"

signal connection_successful
signal connection_failed
signal player_joined(peer_id: int)
signal player_left(peer_id: int)
signal server_disconnected

var last_server_address: String = ""
var reconnect_attempts: int = 0
var peer: ENetMultiplayerPeer
var timeout_timer: Timer

func _ready() -> void:
	_load_last_server()
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	timeout_timer = Timer.new()
	timeout_timer.one_shot = true
	timeout_timer.timeout.connect(_on_timeout)
	add_child(timeout_timer)

## Connects to a server given an address (e.g., 192.168.1.100:10403)
func connect_to_server(address: String) -> void:
	var addr_info: Dictionary = _validate_address(address)
	if not addr_info.is_valid:
		GameManager.report_error("Invalid address format.")
		connection_failed.emit()
		return
		
	last_server_address = address
	_save_last_server()
	
	peer = ENetMultiplayerPeer.new()
	var err: int = peer.create_client(addr_info.ip, addr_info.port)
	if err != OK:
		GameManager.report_error("Failed to create client peer.")
		connection_failed.emit()
		return
		
	multiplayer.multiplayer_peer = peer
	timeout_timer.start(CONNECTION_TIMEOUT)
	GameManager.change_state(GameManager.GameState.CONNECTING)

## Disconnects from the current server
func disconnect_from_server() -> void:
	if peer != null:
		peer.close()
	multiplayer.multiplayer_peer = null
	GameManager.change_state(GameManager.GameState.DISCONNECTED)

## Validates an IP:PORT string. Returns dictionary with ip, port, and is_valid
func _validate_address(address: String) -> Dictionary:
	var result: Dictionary = {"is_valid": false, "ip": "", "port": DEFAULT_PORT}
	if address.is_empty():
		return result
		
	var parts: PackedStringArray = address.split(":")
	result.ip = parts[0]
	
	if parts.size() > 1:
		if parts[1].is_valid_int():
			var p: int = parts[1].to_int()
			if p > 0 and p <= 65535:
				result.port = p
				result.is_valid = true
	else:
		# Use default port if omitted
		result.is_valid = true
		
	# Simple IP validation (not comprehensive, but prevents basic errors)
	if result.ip.count(".") != 3 and result.ip != "localhost":
		result.is_valid = false
		
	return result

func _on_connected_to_server() -> void:
	timeout_timer.stop()
	reconnect_attempts = 0
	GameManager.change_state(GameManager.GameState.CONNECTED)
	connection_successful.emit()

func _on_connection_failed() -> void:
	timeout_timer.stop()
	if reconnect_attempts < MAX_RECONNECT_ATTEMPTS:
		reconnect_attempts += 1
		GameManager.change_state(GameManager.GameState.RECONNECTING)
		# Try again after small delay
		await get_tree().create_timer(1.0).timeout
		connect_to_server(last_server_address)
	else:
		reconnect_attempts = 0
		multiplayer.multiplayer_peer = null
		GameManager.change_state(GameManager.GameState.DISCONNECTED)
		connection_failed.emit()

func _on_server_disconnected() -> void:
	GameManager.change_state(GameManager.GameState.DISCONNECTED)
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()

func _on_peer_connected(id: int) -> void:
	player_joined.emit(id)

func _on_peer_disconnected(id: int) -> void:
	player_left.emit(id)

func _on_timeout() -> void:
	GameManager.report_error("Connection timeout.")
	_on_connection_failed()

func _save_last_server() -> void:
	var config := ConfigFile.new()
	config.set_value("Network", "last_server", last_server_address)
	config.save(LAST_SERVER_FILE)

func _load_last_server() -> void:
	var config := ConfigFile.new()
	if config.load(LAST_SERVER_FILE) == OK:
		last_server_address = config.get_value("Network", "last_server", "")
