# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_balance_metrics_tracks_kills() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("chef")
	metrics.start_wave(1, 1)

	metrics.record_kill(&"chaser")
	metrics.record_kill(&"chaser")
	metrics.record_kill(&"sprinter")

	var summary := metrics.get_current_wave_summary()
	assert_int(summary.get("total_kills", 0)).is_equal(3)

	var kills_by_type: Dictionary = summary.get("kills_by_type", {})
	assert_int(kills_by_type.get("chaser", 0)).is_equal(2)
	assert_int(kills_by_type.get("sprinter", 0)).is_equal(1)


func test_balance_metrics_tracks_damage() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("goblin")
	metrics.start_wave(1, 1)

	metrics.record_damage_dealt(25, "pepper_grinder_gun")
	metrics.record_damage_dealt(30, "pepper_grinder_gun")
	metrics.record_damage_dealt(15, "kitchen_knife")

	var summary := metrics.get_current_wave_summary()
	assert_int(summary.get("damage_dealt", 0)).is_equal(70)

	var damage_by_weapon: Dictionary = summary.get("damage_by_weapon", {})
	assert_int(damage_by_weapon.get("pepper_grinder_gun", 0)).is_equal(55)
	assert_int(damage_by_weapon.get("kitchen_knife", 0)).is_equal(15)


func test_balance_metrics_tracks_damage_taken() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("onion")
	metrics.start_wave(1, 1)

	metrics.record_damage_taken(8)
	metrics.record_damage_taken(8)
	metrics.record_damage_taken(10)

	var summary := metrics.get_current_wave_summary()
	assert_int(summary.get("damage_taken", 0)).is_equal(26)


func test_balance_metrics_tracks_economy() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("cookie")
	metrics.start_wave(1, 1)

	metrics.record_xp_collected(10)
	metrics.record_xp_collected(10)
	metrics.record_xp_collected(30)
	metrics.record_gold_earned(1)
	metrics.record_gold_earned(3)

	var summary := metrics.get_current_wave_summary()
	assert_int(summary.get("xp_collected", 0)).is_equal(50)
	assert_int(summary.get("gold_earned", 0)).is_equal(4)


func test_balance_metrics_calculates_effective_dps() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("mushroom")
	metrics.start_wave(1, 1)

	metrics.record_damage_dealt(120, "garlic_bomb")

	var summary := metrics.get_current_wave_summary()
	assert_float(summary.get("effective_dps", 0.0)).is_greater(0.0)


func test_balance_metrics_tracks_health_pickups() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("vampire")
	metrics.start_wave(1, 1)

	metrics.record_health_pickup()
	metrics.record_health_pickup()

	var summary := metrics.get_current_wave_summary()
	assert_int(summary.get("health_pickups_collected", 0)).is_equal(2)


func test_balance_metrics_tracks_player_levels() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("witch")
	metrics.start_wave(1, 1)

	assert_dict(metrics.get_current_wave_summary()).contains_key("player_level_start")


func test_balance_metrics_run_summary_includes_waves() -> void:
	var metrics := BalanceMetrics.new()
	metrics.start_run("dumpling")

	metrics.start_wave(1, 1)
	metrics.record_kill(&"chaser")
	metrics.end_wave(2)

	var run_summary := metrics.get_run_summary()
	assert_int(run_summary.get("waves_completed", 0)).is_equal(1)
	assert_str(run_summary.get("character_id", "")).is_equal("dumpling")


func test_balance_metrics_is_tracking_returns_expected() -> void:
	var metrics := BalanceMetrics.new()
	assert_bool(metrics.is_tracking()).is_false()

	metrics.start_run("snowman")
	assert_bool(metrics.is_tracking()).is_true()


func test_balance_metrics_without_start_returns_empty() -> void:
	var metrics := BalanceMetrics.new()
	assert_dict(metrics.get_current_wave_summary()).is_empty()
	assert_dict(metrics.get_run_summary()).is_empty()
