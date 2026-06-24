# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	AudioManager._music_duck_depth = 0
	AudioManager.music_volume = 0.4
	AudioManager.master_volume = 0.7
	AudioManager._apply_music_volume()


func after() -> void:
	AudioManager._music_duck_depth = 0
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
