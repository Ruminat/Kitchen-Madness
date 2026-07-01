# GdUnit generated TestSuite
extends GdUnitTestSuite


func before_test() -> void:
	AudioManager._music_duck_depth = 0
	AudioManager.music_volume = 0.4
	AudioManager.master_volume = 0.7
	AudioManager.sfx_volume = 0.5
	AudioManager.mute_all = false
	AudioManager._apply_music_volume()


func after_test() -> void:
	AudioManager._music_duck_depth = 0
	AudioManager.mute_all = false
	AudioManager._apply_music_volume()


func test_duck_music_halves_effective_volume() -> void:
	AudioManager.duck_music()

	assert_int(AudioManager._music_duck_depth).is_equal(1)
	assert_float(AudioManager._get_effective_music_volume()).is_equal_approx(0.14, 0.001)


func test_unduck_music_restores_full_volume() -> void:
	AudioManager.duck_music()
	AudioManager.unduck_music()

	assert_int(AudioManager._music_duck_depth).is_equal(0)
	assert_float(AudioManager._get_effective_music_volume()).is_equal_approx(0.28, 0.001)


func test_nested_duck_requires_matching_unduck() -> void:
	AudioManager.duck_music()
	AudioManager.duck_music()
	AudioManager.unduck_music()

	assert_int(AudioManager._music_duck_depth).is_equal(1)
	assert_float(AudioManager._get_effective_music_volume()).is_equal_approx(0.14, 0.001)

	AudioManager.unduck_music()
	assert_int(AudioManager._music_duck_depth).is_equal(0)
	assert_float(AudioManager._get_effective_music_volume()).is_equal_approx(0.28, 0.001)


func test_shipped_mix_keeps_music_above_sfx() -> void:
	assert_float(AudioManager.DEFAULT_MUSIC_VOLUME).is_greater(AudioManager.DEFAULT_SFX_VOLUME)


func test_player_hurt_plays_quieter_than_default_sfx() -> void:
	var hurt := AudioManager._get_effective_sfx_volume(&"player_hurt")
	var normal := AudioManager._get_effective_sfx_volume(&"enemy_hit")

	assert_float(hurt).is_equal_approx(normal * 0.5, 0.0001)


func test_distance_falloff_attenuates_far_sfx() -> void:
	assert_float(AudioManager._falloff_for_distance(0.0)).is_equal_approx(1.0, 0.0001)
	assert_float(AudioManager._falloff_for_distance(AudioManager.SFX_FALLOFF_NEAR)).is_equal_approx(
		1.0, 0.0001
	)
	assert_float(AudioManager._falloff_for_distance(5000.0)).is_equal_approx(
		AudioManager.SFX_MIN_DISTANCE_VOLUME, 0.0001
	)


func test_distance_falloff_decreases_monotonically() -> void:
	var near := AudioManager._falloff_for_distance(400.0)
	var mid := AudioManager._falloff_for_distance(700.0)
	var far := AudioManager._falloff_for_distance(1000.0)

	assert_float(near).is_greater(mid)
	assert_float(mid).is_greater(far)


func test_music_and_sfx_volume_setters_clamp_values() -> void:
	AudioManager.set_music_volume(1.5, false)
	AudioManager.set_sfx_volume(-0.25, false)

	assert_float(AudioManager.music_volume).is_equal(1.0)
	assert_float(AudioManager.sfx_volume).is_equal(0.0)


func test_mute_all_silences_effective_mix() -> void:
	AudioManager.set_mute_all(true, false)

	assert_float(AudioManager._get_effective_music_volume()).is_equal(0.0)
	assert_float(AudioManager._get_effective_sfx_volume(&"enemy_hit")).is_equal_approx(
		0.00001, 0.000001
	)
