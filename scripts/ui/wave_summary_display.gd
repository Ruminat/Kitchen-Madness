class_name WaveSummaryDisplay
extends Control

## Debug display for end-of-wave balance metrics.

const PanelStyle := preload("res://scripts/ui/panel_style.gd")

var _summary_data: Dictionary = {}

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/TitleLabel
@onready var stats_container: VBoxContainer = $Panel/StatsContainer


func _ready() -> void:
	visible = false
	EventBus.metrics_wave_ended.connect(_on_wave_ended)

	var viewport_size := get_viewport().get_visible_rect().size
	position = Vector2((viewport_size.x - panel.size.x) * 0.5, 100.0)


func _on_wave_ended(summary: Dictionary) -> void:
	_summary_data = summary
	_update_display()
	visible = true
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_summary()


func _close_summary() -> void:
	visible = false
	get_tree().paused = false


func _update_display() -> void:
	if title_label:
		title_label.text = "Wave %d Complete" % _summary_data.get("wave_number", 0)

	if stats_container:
		for child in stats_container.get_children():
			child.queue_free()

		_add_stat_row("Duration", "%.1fs" % _summary_data.get("duration_seconds", 0.0))
		_add_stat_row("Kills", "%d" % _summary_data.get("total_kills", 0))
		_add_stat_row("Effective DPS", "%.1f" % _summary_data.get("effective_dps", 0.0))
		_add_stat_row("Damage Dealt", "%d" % _summary_data.get("damage_dealt", 0))
		_add_stat_row("Damage Taken", "%d" % _summary_data.get("damage_taken", 0))
		_add_stat_row("XP Collected", "%d" % _summary_data.get("xp_collected", 0))
		_add_stat_row("Gold Earned", "%d" % _summary_data.get("gold_earned", 0))
		_add_stat_row("Kills/Min", "%.1f" % _summary_data.get("kills_per_minute", 0.0))
		_add_stat_row("Gold/Min", "%.1f" % _summary_data.get("gold_per_minute", 0.0))
		_add_stat_row(
			"Player Level",
			(
				"%d → %d"
				% [
					_summary_data.get("player_level_start", 0),
					_summary_data.get("player_level_end", 0)
				]
			)
		)

		if _summary_data.has("damage_by_weapon"):
			var weapons: Dictionary = _summary_data.get("damage_by_weapon", {})
			if not weapons.is_empty():
				_add_separator()
				for weapon_id in weapons:
					_add_stat_row("  %s" % weapon_id, "%d" % weapons[weapon_id])

		if _summary_data.has("kills_by_type"):
			var types: Dictionary = _summary_data.get("kills_by_type", {})
			if not types.is_empty():
				_add_separator()
				for enemy_type in types:
					_add_stat_row("  %s" % enemy_type, "%d" % types[enemy_type])

		_add_separator()
		_add_instruction_row("Press ENTER or ESC to continue")


func _add_stat_row(label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value)

	stats_container.add_child(row)


func _add_separator() -> void:
	var separator := HSeparator.new()
	separator.modulate = Color(1.0, 1.0, 1.0, 0.3)
	stats_container.add_child(separator)


func _add_instruction_row(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.modulate = Color(0.8, 0.8, 0.8, 1.0)
	stats_container.add_child(label)
