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
	"wave_complete": "res://assets/audio/sfx/wave_complete.wav",
	"shop_buy": "res://assets/audio/sfx/shop_buy.wav",
	"pickup_xp": "res://assets/audio/sfx/pickup_xp.wav",
	"pickup_health": "res://assets/audio/sfx/pickup_health.wav",
	"pickup_gold": "res://assets/audio/sfx/pickup_gold.wav",
	"weapon_upgrade": "res://assets/audio/sfx/weapon_upgrade.wav",
}

const MUSIC_PATH := "res://assets/audio/music/jrpg_battle_loop.mp3"

# Volume settings (0.0 to 1.0), default 70% for comfortable listening
var master_volume := 0.7:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		_update_all_volumes()

var music_volume := 0.4
var sfx_volume := 0.5

# AudioStreamPlayers pool for SFX
var _sfx_players: Array[AudioStreamPlayer] = []
var _available_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer

# Cached sound effects
var _sfx_cache: Dictionary = {}

# Track gold changes for shop buy sound
var _last_gold := 0


func _ready() -> void:
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
	EventBus.wave_completed.connect(_on_wave_completed)
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
	_sfx_cache["wave_complete"] = _generate_arpeggio([440.0, 554.0, 659.0, 880.0], 0.5)


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


func play_sfx(sound_name: StringName) -> void:
	if _available_players.is_empty():
		return

	var stream: AudioStream = _get_stream(sound_name)
	if stream == null:
		return

	var player: AudioStreamPlayer = _available_players.pop_back()
	player.stream = stream
	player.volume_db = linear_to_db(master_volume * sfx_volume)
	player.play()


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
	if _music_player:
		_music_player.volume_db = linear_to_db(master_volume * music_volume)


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
	_music_player.stream = stream
	_music_player.volume_db = linear_to_db(master_volume * music_volume)
	add_child(_music_player)
	_music_player.play()


func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)


# Signal handlers


func _on_damage_dealt(_world_pos: Vector2, _amount: int, is_crit: bool) -> void:
	if is_crit:
		play_sfx("enemy_hit")


func _on_enemy_killed(_enemy: Node, _killer: Node) -> void:
	play_sfx("enemy_death")


func _on_player_health_changed(current: int, maximum: int) -> void:
	if current < maximum:
		play_sfx("player_hurt")


func _on_level_up(_level: int) -> void:
	play_sfx("level_up")


func _on_wave_completed() -> void:
	play_sfx("wave_complete")


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
