class_name BalanceCalculator
extends RefCounted

## Calculates theoretical balance metrics from data resources.
## Used for comparing predicted vs. actual performance during playtesting.

const DEFAULT_HIT_RATE := 0.7
const MULTI_TARGET_FACTOR := 1.5
const BURST_FACTOR := 2.0

## Target single-target DPS every tier-1 weapon should hit. Re-baselined for the
## Great Rework roster: Kitchen Knife 25/0.8s, Frying Pan 60/1.9s, Rotten Tomato
## 40/1.2s all land near ~32 DPS.
const BASE_DPS_TARGET := 32.0
const BASE_DPS_TOLERANCE := 0.12
const BOOMERANG_HITS_PER_THROW := 2.0


static func single_target_dps(weapon: WeaponDefinition) -> float:
	## Canonical, type-aware sustained DPS against one enemy. Used to keep every
	## tier-1 weapon at parity regardless of delivery mechanic.
	if weapon == null:
		return 0.0

	var fire_rate := maxf(weapon.fire_rate, 0.01)
	var damage := float(weapon.damage)
	var pellets := float(maxi(weapon.pellet_count, 1))

	match weapon.weapon_type:
		WeaponDefinition.WeaponType.ORBIT:
			return damage * pellets * maxf(weapon.orbit_speed, 0.01) / TAU
		WeaponDefinition.WeaponType.MELEE:
			return damage / fire_rate
		WeaponDefinition.WeaponType.BOOMERANG:
			return BOOMERANG_HITS_PER_THROW * damage / fire_rate
		WeaponDefinition.WeaponType.TURRET:
			var shots := weapon.turret_duration / maxf(weapon.turret_fire_rate, 0.01)
			return damage * shots / fire_rate
		_:
			# PROJECTILE and BURST both deliver every pellet per shot.
			return damage * pellets / fire_rate


static func is_base_dps_balanced(weapon: WeaponDefinition) -> bool:
	var dps := single_target_dps(weapon)
	return absf(dps - BASE_DPS_TARGET) <= BASE_DPS_TARGET * BASE_DPS_TOLERANCE


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


static func estimate_level_gold(
	level: LevelDefinition, enemy_roster: Array[EnemyDefinition]
) -> int:
	if level == null or enemy_roster.is_empty():
		return 0

	var estimated_kills := estimate_level_kills(level)
	var avg_gold_per_kill := _calculate_avg_gold(enemy_roster) * DropRates.GREASE_DROP_CHANCE
	return int(estimated_kills * avg_gold_per_kill)


static func estimate_level_xp(level: LevelDefinition, enemy_roster: Array[EnemyDefinition]) -> int:
	if level == null or enemy_roster.is_empty():
		return 0

	var estimated_kills := estimate_level_kills(level)
	var avg_xp_per_kill := _calculate_avg_xp(enemy_roster) * DropRates.XP_DROP_CHANCE
	return int(estimated_kills * avg_xp_per_kill)


static func estimate_level_kills(level: LevelDefinition) -> int:
	if level == null:
		return 0

	var spawn_count := level.duration / maxf(level.spawn_interval, 0.1)
	var avg_multiplier := (level.spawn_multiplier_start + level.spawn_multiplier_end) * 0.5
	var avg_swarm_size := level.average_swarm_size()
	return int(spawn_count * avg_multiplier * avg_swarm_size * level.average_group_count())


static func calculate_level_hp_budget(
	level: LevelDefinition, enemy_roster: Array[EnemyDefinition]
) -> int:
	if level == null or enemy_roster.is_empty():
		return 0

	var avg_hp := _calculate_avg_hp(enemy_roster, level.duration * 0.5)
	var estimated_kills := estimate_level_kills(level)
	return int(estimated_kills * avg_hp)


static func calculate_time_to_level(_level: int, xp_system: XpSystem) -> float:
	if xp_system == null:
		return 0.0

	var xp_needed := xp_system.xp_to_next
	var current_xp := xp_system.current_xp
	return float(xp_needed - current_xp)


static func estimate_levels_per_run(
	level: LevelDefinition, enemy_roster: Array[EnemyDefinition]
) -> float:
	var run_xp := estimate_level_xp(level, enemy_roster)
	var xp_to_level := _xp_required_for_level(2)
	if xp_to_level <= 0:
		return 0.0
	return float(run_xp) / float(xp_to_level)


static func estimate_level_affordability(
	level: LevelDefinition,
	enemy_roster: Array[EnemyDefinition],
	elapsed_seconds: float = 0.0,
	cheap_cost: int = 8,
	weapon_cost: int = 12
) -> Dictionary:
	var grease := estimate_level_gold(level, enemy_roster)
	var scaled_cheap := ShopManager.scaled_cost_for_time(cheap_cost, elapsed_seconds)
	var scaled_weapon := ShopManager.scaled_cost_for_time(weapon_cost, elapsed_seconds)
	return {
		"estimated_grease": grease,
		"cheap_item_cost": scaled_cheap,
		"weapon_item_cost": scaled_weapon,
		"cheap_purchases": float(grease) / float(maxi(scaled_cheap, 1)),
		"weapon_purchases": float(grease) / float(maxi(scaled_weapon, 1)),
	}


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


static func compare_level_budgets(
	levels: Array[LevelDefinition], enemy_roster: Array[EnemyDefinition]
) -> Dictionary:
	var results := {}
	for level in levels:
		if level == null:
			continue
		results[level.resource_path.get_file()] = {
			"duration": level.duration,
			"estimated_kills": estimate_level_kills(level),
			"estimated_gold": estimate_level_gold(level, enemy_roster),
			"estimated_xp": estimate_level_xp(level, enemy_roster),
			"hp_budget": calculate_level_hp_budget(level, enemy_roster),
			"levels_gained": estimate_levels_per_run(level, enemy_roster),
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


static func _calculate_avg_hp(
	enemies: Array[EnemyDefinition], elapsed_seconds: float = 0.0
) -> float:
	if enemies.is_empty():
		return 30.0

	var total := 0.0
	for enemy in enemies:
		if enemy:
			total += float(LevelDefinition.resolve_enemy_health(enemy.max_health, elapsed_seconds))
	return total / enemies.size()


static func _xp_required_for_level(next_level: int) -> int:
	return XpSystem.BASE_XP_TO_LEVEL + (next_level - 1) * XpSystem.XP_PER_LEVEL_GROWTH


static func format_balance_report(report: Dictionary) -> String:
	var lines: Array[String] = ["=== Balance Report ==="]

	if report.has("waves"):
		lines.append("\nWave Summaries:")
		for wave_data in report.get("waves", []):
			lines.append(
				(
					"Wave %d: %d kills, DPS=%.1f, Grease=%d, XP=%d"
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
