extends Control

@onready var quality_option: OptionButton = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/QualityOption
@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/MasterVol/MasterSlider
@onready var music_check: CheckBox = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/MusicVol/MusicCheck
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/MusicVol/MusicSlider
@onready var sfx_check: CheckBox = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/SFXVol/SFXCheck
@onready var sfx_slider: HSlider = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/SFXVol/SFXSlider
@onready var sens_slider: HSlider = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/Sensitivity/SensSlider
@onready var invert_check: CheckBox = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/InvertCamera
@onready var vibration_check: CheckBox = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/Vibration
@onready var language_option: OptionButton = $MarginContainer/VBoxContainer/ScrollContainer/SettingsList/LanguageBox/LanguageOption

@onready var back_btn: Button = $MarginContainer/VBoxContainer/Buttons/BackBtn
@onready var reset_btn: Button = $MarginContainer/VBoxContainer/Buttons/ResetBtn
@onready var save_btn: Button = $MarginContainer/VBoxContainer/Buttons/SaveBtn

func _ready() -> void:
	quality_option.add_item("LOW")
	quality_option.add_item("MEDIUM")
	quality_option.add_item("HIGH")
	
	language_option.add_item("Bahasa Indonesia")
	language_option.add_item("English")
	
	back_btn.pressed.connect(_on_back_pressed)
	reset_btn.pressed.connect(_on_reset_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	
	if has_node("/root/SettingsManager"):
		_load_settings()

func _load_settings() -> void:
	var sm = get_node("/root/SettingsManager")
	# Assuming SettingsManager has these properties
	# quality_option.selected = sm.quality
	# master_slider.value = sm.master_vol
	# ...
	pass

func _on_save_pressed() -> void:
	if has_node("/root/SettingsManager"):
		var sm = get_node("/root/SettingsManager")
		# Save UI values to sm
		# sm.apply_settings()
	_on_back_pressed()

func _on_reset_pressed() -> void:
	# Reset logic
	quality_option.selected = 0
	master_slider.value = 100
	music_check.button_pressed = true
	music_slider.value = 100
	sfx_check.button_pressed = true
	sfx_slider.value = 100
	sens_slider.value = 1.0
	invert_check.button_pressed = false
	vibration_check.button_pressed = true
	language_option.selected = 0

func _on_back_pressed() -> void:
	if has_node("/root/SceneManager"):
		var sm = get_node("/root/SceneManager")
		sm.change_scene(sm.MAIN_MENU) # Should go to previous scene realistically
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
