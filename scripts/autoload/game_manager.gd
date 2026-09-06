extends Node

## Singleton for managing global game state
## Manages game states, player data, and room data.

enum GameState {
	MAIN_MENU,
	SERVER_CONNECT,
	CONNECTING,
	CONNECTED,
	AUTHENTICATING,
	LOBBY,
	LOADING,
	IN_MATCH,
	EXTRACTION,
	RECONNECTING,
	DISCONNECTING,
	DISCONNECTED
}

signal state_changed(old_state: GameState, new_state: GameState)
signal game_error(error_message: String)

var current_state: GameState = GameState.MAIN_MENU
var build_version: String = "0.1.0"

var player_data: Dictionary = {
	"name": "Survivor",
	"id": 1,
	"score": 0,
	"is_ready": false,
	"role": "player"
}

var room_data: Dictionary = {
	"room_id": "",
	"players": {}, # key: peer_id, value: player info
	"mission": "survive"
}

func _ready() -> void:
	# Inisialisasi awal
	print("GameManager initialized. Version: ", build_version)

## Changes the game state safely.
func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	# Validasi state transition bisa ditambah di sini jika perlu
	var old_state: GameState = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
	print("Game state changed: ", _get_state_name(old_state), " -> ", _get_state_name(new_state))

## Emits an error signal for UI or logs to catch.
func report_error(message: String) -> void:
	printerr("Game Error: ", message)
	game_error.emit(message)

func _get_state_name(state: GameState) -> String:
	return GameState.keys()[state]
