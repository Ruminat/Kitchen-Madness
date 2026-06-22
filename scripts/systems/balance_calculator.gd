class_name BalanceCalculator
extends RefCounted

## Calculates theoretical balance metrics from data resources.
## Used for comparing predicted vs. actual performance during playtesting.

const DEFAULT_HIT_RATE := 0.7
const MULTI_TARGET_FACTOR := 1.5
const BURST_FACTOR := 2.0


static func calculate_weapon_dps(
	weapon: WeaponDefinition, hit_rate: float = DEFAULT_HIT_RATE
) -> float:
	if weapon == null:
		return 0.0

	var shots_per_second := 1.0 / maxf(weapon.fire_rate, 0.01)
	var damage_per_shot := float(weapon.damage * weapon.pellet_count)
	return damage_per_shot * shots_per_second * hit_rate


static func calculate_weapon_burst_dps(weapon: WeaponDefinition, targets_hit: int = 3) -> float:
	if weapon == null:
		return 0.0

	var base_dps := calculate_weapon_dps(weapon, 0.5)
	return base_dps * clampi(targets_hit, 1, 10)


static func calculate_orbit_dps(weapon: WeaponDefinition, hit_rate: float = 0.9) -> float:
	if weapon == null:
		return 0.0

	var orbit_time := TAU / maxf(weapon.orbit_speed, 0.1)
	var hits_per_rotation := weapon.pellet_count
	var damage_per_rotation := float(weapon.damage * hits_per_rotation)
	return damage_per_rotation / orbit_time * hit_rate


static func calculate_effective_dps(
	weapon: WeaponDefinition, is_orbit: bool = false, is_burst: bool = false
) -> float:
	if weapon == null:
		return 0.0

	if is_orbit:
		return calculate_orbit_dps(weapon)
	if is_burst:
		return calculate_weapon_burst_dps(weapon)
	return calculate_weapon_dps(weapon)


static func estimate_wave_gold(wave: WaveDefinition, enemy_roster: Array[EnemyDefinition]) -> int:
	if wave == null or enemy_roster.is_empty():
		return 0

	var estimated_kills := estimate_wave_kills(wave)
	var avg_gold_per_kill := _calculate_avg_gold(enemy_roster)
	return int(estimated_kills * avg_gold_per_kill)


static func estimate_wave_xp(wave: WaveDefinition, enemy_roster: Array[EnemyDefinition]) -> int:
	if wave == null or enemy_roster.is_empty():
		return 0

	var estimated_kills := estimate_wave_kills(wave)
	var avg_xp_per_kill := _calculate_avg_xp(enemy_roster)
	return int(estimated_kills * avg_xp_per_kill)


static func estimate_wave_kills(wave: WaveDefinition) -> int:
	if wave == null:
		return 0

	var spawn_count := wave.duration / maxf(wave.spawn_interval, 0.1)
	var avg_multiplier := (wave.spawn_multiplier_start + wave.spawn_multiplier_end) * 0.5
	return int(spawn_count * avg_multiplier)


static func calculate_wave_hp_budget(
	wave: WaveDefinition, enemy_roster: Array[EnemyDefinition]
) -> int:
	if wave == null or enemy_roster.is_empty():
		return 0

	var avg_hp := _calculate_avg_hp(enemy_roster)
	var estimated_kills := estimate_wave_kills(wave)
	return int(estimated_kills * avg_hp)


static func calculate_time_to_level(_level: int, xp_system: XpSystem) -> float:
	if xp_system == null:
		return 0.0

	var xp_needed := xp_system.xp_to_next
	var current_xp := xp_system.current_xp
	return float(xp_needed - current_xp)


static func estimate_levels_per_wave(
	wave: WaveDefinition, enemy_roster: Array[EnemyDefinition]
) -> float:
	var wave_xp := estimate_wave_xp(wave, enemy_roster)
	var xp_to_level := 200
	return float(wave_xp) / float(xp_to_level)


static func compare_weapon_dps(weapons: Array[WeaponDefinition]) -> Dictionary:
	var results := {}
	for weapon in weapons:
		if weapon == null:
			continue
		var w_path := weapon.weapon_script.get_path() if weapon.weapon_script else ""
		var is_orbit := w_path.contains("orbit")
		var is_burst := w_path.contains("burst")
		results[weapon.id] = {
			"base_dps": calculate_weapon_dps(weapon),
			"effective_dps": calculate_effective_dps(weapon, is_orbit, is_burst),
			"damage": weapon.damage,
			"fire_rate": weapon.fire_rate,
			"pellet_count": weapon.pellet_count,
		}
	return results


static func compare_wave_budgets(
	waves: Array[WaveDefinition], enemy_roster: Array[EnemyDefinition]
) -> Dictionary:
	var results := {}
	for wave in waves:
		if wave == null:
			continue
		results[wave.resource_path.get_file()] = {
			"duration": wave.duration,
			"estimated_kills": estimate_wave_kills(wave),
			"estimated_gold": estimate_wave_gold(wave, enemy_roster),
			"estimated_xp": estimate_wave_xp(wave, enemy_roster),
			"hp_budget": calculate_wave_hp_budget(wave, enemy_roster),
			"levels_gained": estimate_levels_per_wave(wave, enemy_roster),
		}
	return results


static func _calculate_avg_gold(enemies: Array[EnemyDefinition]) -> float:
	if enemies.is_empty():
		return 1.0

	var total := 0
	for enemy in enemies:
		total += enemy.gold_reward if enemy else 0
	return float(total) / enemies.size()


static func _calculate_avg_xp(enemies: Array[EnemyDefinition]) -> float:
	if enemies.is_empty():
		return 10.0

	var total := 0
	for enemy in enemies:
		if enemy and enemy.xp_drop:
			total += enemy.xp_drop.value
	return float(total) / enemies.size()


static func _calculate_avg_hp(enemies: Array[EnemyDefinition]) -> float:
	if enemies.is_empty():
		return 30.0

	var total := 0
	for enemy in enemies:
		total += enemy.max_health if enemy else 0
	return float(total) / enemies.size()


static func format_balance_report(report: Dictionary) -> String:
	var lines: Array[String] = ["=== Balance Report ==="]

	if report.has("waves"):
		lines.append("\nWave Summaries:")
		for wave_data in report.get("waves", []):
			lines.append(
				(
					"Wave %d: %d kills, DPS=%.1f, Gold=%d, XP=%d"
					% [
						wave_data.get("wave_number", 0),
						wave_data.get("total_kills", 0),
						wave_data.get("effective_dps", 0.0),
						wave_data.get("gold_earned", 0),
						wave_data.get("xp_collected", 0)
					]
				)
			)

	if report.has("character_id"):
		lines.append("\nCharacter: %s" % report.get("character_id", "unknown"))
		lines.append("Total Time: %.1fs" % report.get("total_run_time", 0.0))
		lines.append("Waves: %d" % report.get("waves_completed", 0))

	return "\n".join(lines)
