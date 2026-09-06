extends Control

@onready var player_list: VBoxContainer = $MarginContainer/VBoxContainer/Content/LeftPanel/PlayerList
@onready var create_room_btn: Button = $MarginContainer/VBoxContainer/Content/RightPanel/CreateRoomBtn
@onready var join_room_btn: Button = $MarginContainer/VBoxContainer/Content/RightPanel/HBoxContainer/JoinRoomBtn
@onready var room_code_input: LineEdit = $MarginContainer/VBoxContainer/Content/RightPanel/HBoxContainer/RoomCodeInput
@onready var ready_btn: Button = $MarginContainer/VBoxContainer/Footer/ReadyBtn
@onready var start_btn: Button = $MarginContainer/VBoxContainer/Footer/StartBtn
@onready var disconnect_btn: Button = $MarginContainer/VBoxContainer/Footer/DisconnectBtn
@onready var mission_select: OptionButton = $MarginContainer/VBoxContainer/Footer/MissionSelect
@onready var server_info: Label = $MarginContainer/VBoxContainer/Header/ServerInfo

var players_in_room: Dictionary = {} # peer_id -> {name, ready}
var is_ready: bool = false
var is_host: bool = false

func _ready() -> void:
	create_room_btn.pressed.connect(_on_create_room_pressed)
	join_room_btn.pressed.connect(_on_join_room_pressed)
	ready_btn.pressed.connect(_on_ready_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	disconnect_btn.pressed.connect(_on_disconnect_pressed)
	
	mission_select.add_item("Survive 5 Minutes")
	mission_select.add_item("Collect 5 Items")
	
	if has_node("/root/NetworkManager"):
		var nm = get_node("/root/NetworkManager")
		server_info.text = "Server: " + str(nm.get("last_server_address"))
		# Update UI based on initial multiplayer state
	
	# Add self
	var my_id = multiplayer.get_unique_id()
	players_in_room[my_id] = {"name": "Player_" + str(my_id), "ready": false}
	update_player_list()

func _on_create_room_pressed() -> void:
	is_host = true
	start_btn.visible = true
	rpc("sync_room_state", players_in_room)
	# Logic to create room on server

func _on_join_room_pressed() -> void:
	var code = room_code_input.text.strip_edges()
	if code.is_empty(): return
	is_host = false
	start_btn.visible = false
	# Logic to join room on server

func _on_ready_pressed() -> void:
	is_ready = !is_ready
	ready_btn.text = "UNREADY" if is_ready else "READY"
	rpc("update_player_ready", multiplayer.get_unique_id(), is_ready)

func _on_start_pressed() -> void:
	if is_host and _all_ready():
		rpc("start_game")

func _on_disconnect_pressed() -> void:
	if has_node("/root/NetworkManager"):
		get_node("/root/NetworkManager").disconnect_from_server()
	if has_node("/root/SceneManager"):
		get_node("/root/SceneManager").change_scene(get_node("/root/SceneManager").MAIN_MENU)
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func update_player_list() -> void:
	for child in player_list.get_children():
		if child.name != "Label":
			child.queue_free()
			
	for peer_id in players_in_room:
		var info = players_in_room[peer_id]
		var lbl = Label.new()
		lbl.text = info["name"] + (" (Ready)" if info["ready"] else " (Not Ready)")
		player_list.add_child(lbl)
		
	start_btn.disabled = not _all_ready()

func _all_ready() -> bool:
	for peer_id in players_in_room:
		if not players_in_room[peer_id]["ready"]:
			return false
	return true

@rpc("any_peer", "call_local", "reliable")
func update_player_ready(peer_id: int, rdy: bool) -> void:
	if players_in_room.has(peer_id):
		players_in_room[peer_id]["ready"] = rdy
		update_player_list()

@rpc("any_peer", "call_local", "reliable")
func sync_room_state(room_data: Dictionary) -> void:
	players_in_room = room_data
	update_player_list()

@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	if has_node("/root/SceneManager"):
		get_node("/root/SceneManager").change_scene(get_node("/root/SceneManager").GAME_WORLD)
	else:
		get_tree().change_scene_to_file("res://scenes/game/game_world.tscn")
