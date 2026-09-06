extends Node

## Singleton for audio management
## Handles music, 2D UI SFX, and 3D positional SFX using object pooling.

const MAX_SFX_3D: int = 8

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer3D] = []
var _sfx_2d_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Initialize music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	
	# Initialize 3D SFX pool
	for i in range(MAX_SFX_3D):
		var p := AudioStreamPlayer3D.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
		
	# Initialize 2D SFX pool (for UI)
	for i in range(4):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_2d_players.append(p)

## Plays a music stream, optionally fading in
func play_music(stream: AudioStream, fade_in: float = 1.0) -> void:
	if not SettingsManager.music_enabled:
		return
		
	_music_player.stream = stream
	_music_player.play()
	
	if fade_in > 0.0:
		var tween := create_tween()
		_music_player.volume_db = -80.0
		var target_db := linear_to_db(SettingsManager.music_volume)
		tween.tween_property(_music_player, "volume_db", target_db, fade_in)

## Stops the current music, optionally fading out
func stop_music(fade_out: float = 1.0) -> void:
	if fade_out > 0.0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_out)
		tween.tween_callback(func(): _music_player.stop())
	else:
		_music_player.stop()

## Plays a 3D sound at a specific position
func play_sfx(stream: AudioStream, pos: Vector3 = Vector3.ZERO) -> void:
	if not SettingsManager.sfx_enabled:
		return
		
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.global_position = pos
			p.play()
			return
			
	# If all busy, steal the oldest one (first in array theoretically or just first one)
	_sfx_players[0].stream = stream
	_sfx_players[0].global_position = pos
	_sfx_players[0].play()

## Plays a 2D sound for UI and global effects
func play_sfx_2d(stream: AudioStream) -> void:
	if not SettingsManager.sfx_enabled:
		return
		
	for p in _sfx_2d_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
			
	_sfx_2d_players[0].stream = stream
	_sfx_2d_players[0].play()

## Sets a specific bus volume using linear float (0.0 to 1.0)
func set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		# linear_volume of 0 means -inf db
		var db_vol := linear_to_db(max(linear_volume, 0.0001))
		if linear_volume <= 0.0:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			AudioServer.set_bus_volume_db(bus_idx, db_vol)
