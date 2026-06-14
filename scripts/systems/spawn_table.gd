class_name SpawnTable
extends RefCounted


static func pick_weighted(entries: Array, roll: int = -1) -> EnemyDefinition:
	if entries.is_empty():
		return null

	var total_weight := 0
	for entry in entries:
		if entry is EnemySpawnEntry and entry.definition:
			total_weight += maxi(entry.weight, 1)

	if total_weight <= 0:
		return null

	var pick := roll if roll >= 0 else randi() % total_weight
	for entry in entries:
		if entry == null or not entry is EnemySpawnEntry or entry.definition == null:
			continue
		pick -= maxi(entry.weight, 1)
		if pick < 0:
			return entry.definition

	var first: EnemySpawnEntry = entries[0]
	if first is EnemySpawnEntry:
		return first.definition
	return null
