extends Control

@onready var address_input: LineEdit = $CenterContainer/VBoxContainer/AddressInput
@onready var connect_button: Button = $CenterContainer/VBoxContainer/ConnectButton
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel
@onready var loading_spinner: Control = $CenterContainer/VBoxContainer/LoadingSpinner

var connection_timer: Timer

func _ready() -> void:
	if has_node("/root/NetworkManager"):
		var nm = get_node("/root/NetworkManager")
		if nm.get("last_server_address"):
			address_input.text = nm.last_server_address
			_on_address_changed(address_input.text)
		
		# Connect signals if NetworkManager has them
		if nm.has_signal("connection_successful"):
			nm.connection_successful.connect(_on_connection_successful)
		if nm.has_signal("connection_failed"):
			nm.connection_failed.connect(_on_connection_failed)
			
	address_input.text_changed.connect(_on_address_changed)
	connect_button.pressed.connect(_on_connect_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	connection_timer = Timer.new()
	connection_timer.one_shot = true
	connection_timer.wait_time = 12.0
	connection_timer.timeout.connect(_on_connection_timeout)
	add_child(connection_timer)

func _process(delta: float) -> void:
	if loading_spinner.visible:
		loading_spinner.rotation += delta * 5.0

func _on_address_changed(text: String) -> void:
	connect_button.disabled = text.strip_edges().is_empty()

func _on_connect_pressed() -> void:
	var address = address_input.text.strip_edges()
	if address.is_empty(): return
	
	status_label.text = "Connecting to " + address + "..."
	loading_spinner.visible = true
	connect_button.disabled = true
	address_input.editable = false
	
	if has_node("/root/NetworkManager"):
		get_node("/root/NetworkManager").connect_to_server(address)
	
	connection_timer.start()

func _on_back_pressed() -> void:
	connection_timer.stop()
	if has_node("/root/SceneManager"):
		var sm = get_node("/root/SceneManager")
		sm.change_scene(sm.MAIN_MENU)
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_connection_successful() -> void:
	connection_timer.stop()
	status_label.text = "Connected!"
	loading_spinner.visible = false
	if has_node("/root/SceneManager"):
		var sm = get_node("/root/SceneManager")
		sm.change_scene(sm.LOBBY)
	else:
		get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")

func _on_connection_failed() -> void:
	connection_timer.stop()
	_show_error("Connection failed.")

func _on_connection_timeout() -> void:
	_show_error("Connection timed out.")

func _show_error(msg: String) -> void:
	status_label.text = msg
	loading_spinner.visible = false
	connect_button.disabled = false
	connect_button.text = "RETRY"
	address_input.editable = true
