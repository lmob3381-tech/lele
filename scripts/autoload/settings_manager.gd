extends Node

## Singleton for application and graphics settings
## Manages persistence via ConfigFile.

enum GraphicsQuality {LOW, MEDIUM, HIGH}

const SETTINGS_FILE: String = "user://settings.cfg"

# Graphics
var graphics_quality: GraphicsQuality = GraphicsQuality.LOW

# Audio
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var music_enabled: bool = true
var sfx_enabled: bool = true

# Gameplay / Input
var camera_sensitivity: float = 0.5
var invert_camera: bool = false
var vibration_enabled: bool = true
var language: String = "id"

func _ready() -> void:
	load_settings()
	apply_all_settings()

## Saves all settings to disk
func save_settings() -> void:
	var config := ConfigFile.new()
	
	config.set_value("Graphics", "quality", graphics_quality)
	
	config.set_value("Audio", "master", master_volume)
	config.set_value("Audio", "music", music_volume)
	config.set_value("Audio", "sfx", sfx_volume)
	config.set_value("Audio", "music_enabled", music_enabled)
	config.set_value("Audio", "sfx_enabled", sfx_enabled)
	
	config.set_value("Gameplay", "sensitivity", camera_sensitivity)
	config.set_value("Gameplay", "invert_camera", invert_camera)
	config.set_value("Gameplay", "vibration", vibration_enabled)
	config.set_value("Gameplay", "language", language)
	
	config.save(SETTINGS_FILE)

## Loads settings from disk
func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE) != OK:
		return # Use defaults if no file
		
	graphics_quality = config.get_value("Graphics", "quality", GraphicsQuality.LOW)
	
	master_volume = config.get_value("Audio", "master", 1.0)
	music_volume = config.get_value("Audio", "music", 0.8)
	sfx_volume = config.get_value("Audio", "sfx", 1.0)
	music_enabled = config.get_value("Audio", "music_enabled", true)
	sfx_enabled = config.get_value("Audio", "sfx_enabled", true)
	
	camera_sensitivity = config.get_value("Gameplay", "sensitivity", 0.5)
	invert_camera = config.get_value("Gameplay", "invert_camera", false)
	vibration_enabled = config.get_value("Gameplay", "vibration", true)
	language = config.get_value("Gameplay", "language", "id")

func apply_all_settings() -> void:
	apply_graphics_quality()
	apply_audio_settings()
	TranslationServer.set_locale(language)

## Applies graphics adjustments based on the selected quality
func apply_graphics_quality() -> void:
	var viewport := get_viewport()
	match graphics_quality:
		GraphicsQuality.LOW:
			viewport.scaling_3d_scale = 0.7
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			# Shadows might be disabled via Environment or DirectionalLight3D settings per scene
		GraphicsQuality.MEDIUM:
			viewport.scaling_3d_scale = 0.85
			viewport.msaa_3d = Viewport.MSAA_DISABLED
		GraphicsQuality.HIGH:
			viewport.scaling_3d_scale = 1.0
			viewport.msaa_3d = Viewport.MSAA_2X

## Updates audio buses based on volume and enabled toggles
func apply_audio_settings() -> void:
	if has_node("/root/AudioManager"):
		var am: Node = get_node("/root/AudioManager")
		am.set_bus_volume("Master", master_volume)
		am.set_bus_volume("Music", music_volume if music_enabled else 0.0)
		am.set_bus_volume("SFX", sfx_volume if sfx_enabled else 0.0)
