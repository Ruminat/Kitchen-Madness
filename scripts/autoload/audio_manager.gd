extends Node
## Global audio manager for one-shot SFX and music.

const MAX_SFX_PLAYERS := 16

# Sound effect paths (expected locations - can be replaced with actual files)
const SFX_PATHS := {
	"enemy_hit": "res://assets/audio/sfx/enemy_hit.wav",
	"enemy_death": "res://assets/audio/sfx/enemy_death.wav",
	"player_hurt": "res://assets/audio/sfx/player_hurt.wav",
	"shoot_default": "res://assets/audio/sfx/shoot_default.wav",
	"shoot_shotgun": "res://assets/audio/sfx/shoot_shotgun.wav",
	"level_up": "res://assets/audio/sfx/level_up.wav",
	"victory": "res://assets/audio/sfx/victory.wav",
	"shop_buy": "res://assets/audio/sfx/shop_buy.wav",
	"pickup_xp": "res://assets/audio/sfx/pickup_xp.wav",
	"pickup_health": "res://assets/audio/sfx/pickup_health.wav",
	"pickup_gold": "res://assets/audio/sfx/pickup_gold.wav",
	"weapon_upgrade": "res://assets/audio/sfx/weapon_upgrade.wav",
}

const MUSIC_PATH := "res://assets/audio/music/jrpg_battle_loop.mp3"
const MENU_DUCK_FACTOR := 0.5
const CONFIG_PATH := "user://settings.cfg"
const CONFIG_SECTION := "audio"
const CONFIG_MUSIC_VOLUME := "music_volume"
const CONFIG_SFX_VOLUME := "sfx_volume"
const CONFIG_MUTE_ALL := "mute_all"

# Shipped mix: music dominates, gameplay SFX sit under it (Music > SFX).
const DEFAULT_MUSIC_VOLUME := 0.7
const DEFAULT_SFX_VOLUME := 0.32

# Per-sound volume trims (1.0 = default) so the harshest hits do not dominate.
const SFX_VOLUME_SCALE := {
	"player_hurt": 0.5,
}

# One-shot SFX distance attenuation, in world units from the player/listener.
const SFX_FALLOFF_NEAR := 300.0
const SFX_FALLOFF_FAR := 1150.0
const SFX_MIN_DISTANCE_VOLUME := 0.2

# Volume settings (0.0 to 1.0), default 70% master for comfortable listening.
var master_volume := 0.7:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_update_all_volumes()

var music_volume := DEFAULT_MUSIC_VOLUME:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		_update_all_volumes()

var sfx_volume := DEFAULT_SFX_VOLUME:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		_update_all_volumes()

var mute_all := false:
	set(value):
		mute_all = value
		_update_all_volumes()

# AudioStreamPlayers pool for SFX
var _sfx_players: Array[AudioStreamPlayer] = []
var _available_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _music_duck_depth := 0
var _music_volume_tween: Tween

# Cached sound effects
var _sfx_cache: Dictionary = {}

# Track gold changes for shop buy sound
var _last_gold := 0

# Cached player node used as the listener for positional SFX falloff
var _cached_listener: Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()
	_initialize_sfx_players()
	_connect_signals()
	_generate_placeholder_sounds()
	_start_music()


func _initialize_sfx_players() -> void:
	for i in MAX_SFX_PLAYERS:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)
		_available_players.append(player)
		player.finished.connect(_on_player_finished.bind(player))


func _connect_signals() -> void:
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.pickup_collected.connect(_on_pickup_collected)
	EventBus.gold_changed.connect(_on_gold_changed)


func _generate_placeholder_sounds() -> void:
	# Generate simple synthesized sounds as placeholders
	# These will be replaced when actual audio files are added
	_sfx_cache["pickup_xp"] = _generate_beep(880.0, 0.1)
	_sfx_cache["pickup_gold"] = _generate_beep(1100.0, 0.08)
	_sfx_cache["pickup_health"] = _generate_beep(660.0, 0.15)
	_sfx_cache["enemy_hit"] = _generate_noise_burst(0.05)
	_sfx_cache["enemy_death"] = _generate_noise_burst(0.15)
	_sfx_cache["player_hurt"] = _generate_beep(220.0, 0.2)
	_sfx_cache["shop_buy"] = _generate_beep(1200.0, 0.12)
	_sfx_cache["shoot_default"] = _generate_noise_burst(0.08)
	_sfx_cache["shoot_shotgun"] = _generate_noise_burst(0.12)
	_sfx_cache["weapon_upgrade"] = _generate_beep(990.0, 0.2)
	_sfx_cache["level_up"] = _generate_arpeggio([523.0, 659.0, 784.0, 1047.0], 0.4)
	_sfx_cache["victory"] = _generate_arpeggio([440.0, 554.0, 659.0, 880.0], 0.5)


func _generate_beep(frequency: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 44100
	var num_samples := int(sample_rate * duration)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED

	var data := PackedByteArray()
	data.resize(num_samples * 2)

	for i in num_samples:
		var t := float(i) / sample_rate
		var sample := sin(t * frequency * TAU)
		# Apply simple envelope
		var envelope := 1.0
		if t < 0.01:
			envelope = t / 0.01
		elif t > duration - 0.05:
			envelope = maxf(0.0, (duration - t) / 0.05)
		sample *= envelope

		var int_sample := int(clampf(sample * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, int_sample)

	wav.data = data
	wav.mix_rate = sample_rate
	return wav


func _generate_noise_burst(duration: float) -> AudioStreamWAV:
	var sample_rate := 44100
	var num_samples := int(sample_rate * duration)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED

	var data := PackedByteArray()
	data.resize(num_samples * 2)

	for i in num_samples:
		var t := float(i) / sample_rate
		var sample := randf() * 2.0 - 1.0
		# Apply exponential decay envelope
		var envelope := exp(-t * 10.0)
		sample *= envelope

		var clamped := clampf(sample * 32767.0 * 0.5, -32768.0, 32767.0)
		var int_sample := int(clamped)
		data.encode_s16(i * 2, int_sample)

	wav.data = data
	wav.mix_rate = sample_rate
	return wav


func _generate_arpeggio(freqs: Array, total_dur: float) -> AudioStreamWAV:
	var sample_rate := 44100
	var num_samples := int(sample_rate * total_dur)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED

	var data := PackedByteArray()
	data.resize(num_samples * 2)

	var note_duration := total_dur / freqs.size()

	for i in num_samples:
		var t := float(i) / sample_rate
		var note_idx := mini(int(t / note_duration), freqs.size() - 1)
		var note_time := t - (note_idx * note_duration)
		var frequency: float = freqs[note_idx]

		var sample := sin(note_time * frequency * TAU)
		# Apply envelope per note
		var envelope := 1.0
		if note_time < 0.01:
			envelope = note_time / 0.01
		elif note_time > note_duration - 0.05:
			envelope = maxf(0.0, (note_duration - note_time) / 0.05)
		sample *= envelope * 0.5

		var int_sample := int(clampf(sample * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, int_sample)

	wav.data = data
	wav.mix_rate = sample_rate
	return wav


func play_sfx(sound_name: StringName, volume_scale := 1.0) -> void:
	if _available_players.is_empty():
		return

	var stream: AudioStream = _get_stream(sound_name)
	if stream == null:
		return

	var player: AudioStreamPlayer = _available_players.pop_back()
	player.stream = stream
	player.volume_db = linear_to_db(_get_effective_sfx_volume(sound_name, volume_scale))
	player.play()


## Plays a one-shot SFX attenuated by the listener's distance from world_pos.
func play_sfx_at(sound_name: StringName, world_pos: Vector2, volume_scale := 1.0) -> void:
	play_sfx(sound_name, volume_scale * _distance_attenuation(world_pos))


func play_shoot_sound(weapon_type: String = "default") -> void:
	match weapon_type:
		"shotgun", "burst":
			play_sfx("shoot_shotgun")
		_:
			play_sfx("shoot_default")


func _get_stream(sound_name: StringName) -> AudioStream:
	# Check cache first
	if _sfx_cache.has(sound_name):
		return _sfx_cache[sound_name]

	# Try to load from disk
	if SFX_PATHS.has(sound_name):
		var path: String = SFX_PATHS[sound_name]
		if FileAccess.file_exists(path):
			var loaded_stream: Resource = load(path)
			var stream: AudioStream = loaded_stream as AudioStream
			if stream != null:
				_sfx_cache[sound_name] = stream
				return stream

	return null


func _on_player_finished(player: AudioStreamPlayer) -> void:
	if player not in _available_players:
		_available_players.append(player)


func _update_all_volumes() -> void:
	for player in _sfx_players:
		player.volume_db = linear_to_db(master_volume * sfx_volume)
	_apply_music_volume()


func _get_effective_music_volume() -> float:
	if mute_all:
		return 0.0
	var volume := music_volume
	if _music_duck_depth > 0:
		volume *= MENU_DUCK_FACTOR
	return master_volume * volume


func _get_effective_sfx_volume(sound_name: StringName = &"", volume_scale := 1.0) -> float:
	if mute_all:
		return 0.00001
	var scale := volume_scale * float(SFX_VOLUME_SCALE.get(sound_name, 1.0))
	return maxf(master_volume * sfx_volume * scale, 0.00001)


func _distance_attenuation(world_pos: Vector2) -> float:
	var listener := _get_listener()
	if listener == null:
		return 1.0
	return _falloff_for_distance(listener.global_position.distance_to(world_pos))


func _falloff_for_distance(distance: float) -> float:
	if distance <= SFX_FALLOFF_NEAR:
		return 1.0
	if distance >= SFX_FALLOFF_FAR:
		return SFX_MIN_DISTANCE_VOLUME
	var t := (distance - SFX_FALLOFF_NEAR) / (SFX_FALLOFF_FAR - SFX_FALLOFF_NEAR)
	return lerpf(1.0, SFX_MIN_DISTANCE_VOLUME, t)


func _get_listener() -> Node2D:
	if not is_instance_valid(_cached_listener):
		_cached_listener = get_tree().get_first_node_in_group("player") as Node2D
	return _cached_listener


func duck_music(fade_duration := 0.0) -> void:
	_music_duck_depth += 1
	_apply_music_volume(fade_duration)


func unduck_music(fade_duration := 0.0) -> void:
	_music_duck_depth = maxi(_music_duck_depth - 1, 0)
	_apply_music_volume(fade_duration)


func _apply_music_volume(fade_duration := 0.0) -> void:
	if _music_player == null:
		return

	var target_db := linear_to_db(maxf(_get_effective_music_volume(), 0.00001))
	if fade_duration > 0.0:
		if _music_volume_tween and _music_volume_tween.is_valid():
			_music_volume_tween.kill()
		_music_volume_tween = create_tween()
		_music_volume_tween.tween_property(_music_player, "volume_db", target_db, fade_duration)
	else:
		_music_player.volume_db = target_db


func _start_music() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not FileAccess.file_exists(MUSIC_PATH):
		return

	var stream: AudioStream = load(MUSIC_PATH) as AudioStream
	if stream == null:
		return

	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true

	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.stream = stream
	_music_player.volume_db = linear_to_db(_get_effective_music_volume())
	add_child(_music_player)
	_music_player.play()


func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)


func set_music_volume(volume: float, save := true) -> void:
	music_volume = volume
	if save:
		_save_settings()


func set_sfx_volume(volume: float, save := true) -> void:
	sfx_volume = volume
	if save:
		_save_settings()


func set_mute_all(enabled: bool, save := true) -> void:
	mute_all = enabled
	if save:
		_save_settings()


func _load_settings() -> void:
	var config := ConfigFile.new()
	var result := config.load(CONFIG_PATH)
	if result != OK:
		return

	music_volume = float(config.get_value(CONFIG_SECTION, CONFIG_MUSIC_VOLUME, music_volume))
	sfx_volume = float(config.get_value(CONFIG_SECTION, CONFIG_SFX_VOLUME, sfx_volume))
	mute_all = bool(config.get_value(CONFIG_SECTION, CONFIG_MUTE_ALL, mute_all))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(CONFIG_SECTION, CONFIG_MUSIC_VOLUME, music_volume)
	config.set_value(CONFIG_SECTION, CONFIG_SFX_VOLUME, sfx_volume)
	config.set_value(CONFIG_SECTION, CONFIG_MUTE_ALL, mute_all)
	config.save(CONFIG_PATH)


# Signal handlers


func _on_damage_dealt(world_pos: Vector2, _amount: int, is_crit: bool) -> void:
	if is_crit:
		play_sfx_at("enemy_hit", world_pos)


func _on_enemy_killed(enemy: Node, _killer: Node) -> void:
	var enemy_node := enemy as Node2D
	if enemy_node:
		play_sfx_at("enemy_death", enemy_node.global_position)
	else:
		play_sfx("enemy_death")


func _on_player_health_changed(current: int, maximum: int) -> void:
	if current < maximum:
		play_sfx("player_hurt")


func _on_level_up(_level: int) -> void:
	play_sfx("level_up")


func _on_level_completed() -> void:
	play_sfx("victory")


func _on_pickup_collected(type: StringName, _world_pos: Vector2, _value: int) -> void:
	match type:
		&"xp":
			play_sfx("pickup_xp")
		&"health":
			play_sfx("pickup_health")
		&"gold":
			play_sfx("pickup_gold")


func _on_gold_changed(new_gold: int) -> void:
	if new_gold > _last_gold:
		play_sfx("shop_buy")
	_last_gold = new_gold
