extends Control

@onready var play_button: Button = $CenterContainer/VBoxContainer/MarginContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var version_label: Label = $VersionLabel

func _ready() -> void:
	# Don't connect to server here (lightweight)
	if has_node("/root/GameManager") and get_node("/root/GameManager").has_method("get_build_version"):
		version_label.text = get_node("/root/GameManager").get_build_version()
	
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_pressed() -> void:
	if has_node("/root/SceneManager"):
		var sm = get_node("/root/SceneManager")
		sm.change_scene(sm.SERVER_CONNECT)
	else:
		get_tree().change_scene_to_file("res://scenes/server_connect/server_connect.tscn")

func _on_settings_pressed() -> void:
	if has_node("/root/SceneManager"):
		var sm = get_node("/root/SceneManager")
		sm.change_scene(sm.SETTINGS)
	else:
		get_tree().change_scene_to_file("res://scenes/settings/settings_menu.tscn")
