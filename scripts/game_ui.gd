extends CanvasLayer

signal upgrade_selected(upgrade: Resource)
signal shop_purchase_requested(upgrade: Resource)
signal shop_reroll_requested
signal shop_continue_requested
signal character_selected(definition: CharacterDefinition)

const COLOR_TEXT := Color(0.12, 0.08, 0.045, 1.0)
const COLOR_MUTED := Color(0.38, 0.28, 0.18, 1.0)
const COLOR_GREASE := Color(0.98, 0.72, 0.13, 1.0)
const COLOR_PARCHMENT := Color(0.78, 0.67, 0.46, 0.98)
const COLOR_PARCHMENT_DARK := Color(0.48, 0.37, 0.23, 1.0)
const COLOR_METAL := Color(0.16, 0.15, 0.13, 0.94)
const COLOR_BAR_BG := Color(0.18, 0.12, 0.07, 1.0)
const COLOR_BAR_FILL := Color(0.78, 0.12, 0.08, 1.0)
const COLOR_BAR_FILL_LOW := Color(0.96, 0.36, 0.12, 1.0)
const COLOR_XP_FILL := Color(0.74, 0.13, 0.07, 1.0)
const COLOR_XP_FLASH := Color(1.0, 0.44, 0.18, 1.0)
const COLOR_LEVEL_UP_ACCENT := Color(0.37, 0.66, 0.21, 1.0)
const COLOR_CHARACTER_ACCENT := Color(0.86, 0.61, 0.18, 1.0)
const COLOR_SETTINGS_ACCENT := Color(0.28, 0.49, 0.46, 1.0)
const DISPLAY_FONT := preload("res://assets/fonts/bangers.ttf")
const BODY_FONT := preload("res://assets/fonts/jersey15.ttf")
const STAT_BAR_SCRIPT := preload("res://scripts/ui/stat_bar.gd")
const ShopCard = preload("res://scripts/ui/shop_card.gd")
const HudThemeScript = preload("res://scripts/ui/hud_theme.gd")
const WeaponBeltScript = preload("res://scripts/ui/weapon_belt.gd")
const ReferenceHudLayoutScript = preload("res://scripts/ui/reference_hud_layout.gd")
const CompactNumberFormat = preload("res://scripts/compact_number_format.gd")
const SHOP_HINT_TEXT := "W/S between rows  |  A/D between cards  |  1-4 buy  |  Enter continue"

const SHOP_HINT_TEXT_FIXED := "W/S rows  |  A/D cards  |  1-5 buy  |  R reroll  |  Enter continue"
const SHOP_TRANSITION_DURATION := 0.5

var _kills := 0
var _current_wave := 1
var _current_gold := 0
var _timer_pulse_tween: Tween
var _xp_flash_tween: Tween
var _upgrade_buttons: Array[Button] = []
var _upgrade_choices: Array[Resource] = []
var _shop_cards: Array[Button] = []
var _shop_upgrades: Array[Resource] = []
var _shop_sold_slots: Array[bool] = []
var _current_reroll_cost := 0
var _character_buttons: Array[Button] = []
var _character_choices: Array[CharacterDefinition] = []
var _settings_paused_tree := false
var _weapon_belt: PanelContainer

@onready var hp_bar: ProgressBar = $HudPanel/MarginContainer/VBox/HPRow/HPBar
@onready var hp_label: Label = $HudPanel/MarginContainer/VBox/HPRow/HPLabel
@onready var hp_value_label: Label = $HudPanel/MarginContainer/VBox/HPRow/HPValue
@onready var timer_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/TimerLabel
@onready var kill_label: Label = $HudPanel/MarginContainer/VBox/StatsRow/KillLabel
@onready var grease_counter: Control = $GreaseCounter
@onready var grease_title_label: Label = $GreaseCounter/Content/Row/TextStack/GreaseTitleLabel
@onready var gold_label: Label = $GreaseCounter/Content/Row/TextStack/GoldLabel
@onready var hud_panel: PanelContainer = $HudPanel
@onready var xp_panel: PanelContainer = $XpPanel
@onready var xp_bar: ProgressBar = $XpPanel/MarginContainer/HBox/XpBar
@onready var level_label: Label = $XpPanel/MarginContainer/HBox/LevelLabel
@onready var overlay: ColorRect = $Overlay
@onready var overlay_label: Label = $Overlay/CenterContainer/VBox/OverlayLabel
@onready var restart_hint: Label = $Overlay/CenterContainer/VBox/RestartHint
@onready var restart_button: Button = $Overlay/CenterContainer/VBox/RestartButton
@onready var level_up_overlay: ColorRect = $LevelUpOverlay
@onready var level_up_panel: PanelContainer = $LevelUpOverlay/CenterContainer/PanelContainer
@onready var level_up_title_label: Label = (
	get_node("LevelUpOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/TitleLabel")
	as Label
)
@onready var level_up_hint_label: Label = (
	get_node("LevelUpOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/HintLabel")
	as Label
)
@onready var upgrade_button_1: Button = (
	get_node(
		(
			"LevelUpOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/UpgradeChoices/UpgradeButton1"
		)
	)
	as Button
)
@onready var upgrade_button_2: Button = (
	get_node(
		(
			"LevelUpOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/UpgradeChoices/UpgradeButton2"
		)
	)
	as Button
)
@onready var upgrade_button_3: Button = (
	get_node(
		(
			"LevelUpOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/UpgradeChoices/UpgradeButton3"
		)
	)
	as Button
)
@onready var shop_overlay: ColorRect = $ShopOverlay
@onready var shop_panel: PanelContainer = $ShopOverlay/CenterContainer/PanelContainer
@onready var shop_title_label: Label = (
	get_node("ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/TitleLabel")
	as Label
)
@onready var shop_gold_label: Label = (
	get_node("ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/GoldLabel")
	as Label
)
@onready var shop_hint_label: Label = (
	get_node("ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/HintLabel")
	as Label
)
@onready var shop_grid: GridContainer = (
	get_node("ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/ShopGrid")
	as GridContainer
)
@onready var shop_card_1: ShopCard = (
	get_node(
		"ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/ShopGrid/ShopCard1"
	)
	as ShopCard
)
@onready var shop_card_2: ShopCard = (
	get_node(
		"ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/ShopGrid/ShopCard2"
	)
	as ShopCard
)
@onready var shop_card_3: ShopCard = (
	get_node(
		"ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/ShopGrid/ShopCard3"
	)
	as ShopCard
)
@onready var shop_card_4: ShopCard = (
	get_node(
		"ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/ShopGrid/ShopCard4"
	)
	as ShopCard
)
@onready var shop_card_5: ShopCard = (
	get_node(
		"ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/ShopGrid/ShopCard5"
	)
	as ShopCard
)
@onready var shop_reroll_button: Button = (
	get_node(
		(
			"ShopOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/ActionsRow/RerollButton"
		)
	)
	as Button
)
@onready var shop_reroll_cost_label: Label = (
	get_node(
		"ShopOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/ActionsRow/RerollCost"
	)
	as Label
)
@onready var shop_continue_button: Button = (
	get_node(
		(
			"ShopOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/ActionsRow/ContinueButton"
		)
	)
	as Button
)
@onready var character_select_overlay: ColorRect = $CharacterSelectOverlay
@onready var character_select_panel: PanelContainer = (
	$CharacterSelectOverlay/CenterContainer/PanelContainer as PanelContainer
)
@onready var character_select_title_label: Label = (
	get_node(
		"CharacterSelectOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/TitleLabel"
	)
	as Label
)
@onready var character_select_hint_label: Label = (
	get_node(
		"CharacterSelectOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/HintLabel"
	)
	as Label
)
@onready var character_grid: GridContainer = (
	get_node(
		(
			"CharacterSelectOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/CharacterGrid"
		)
	)
	as GridContainer
)
@onready var character_preview_panel: PanelContainer = (
	get_node(
		(
			"CharacterSelectOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/PreviewRow/PreviewPanel"
		)
	)
	as PanelContainer
)
@onready var character_preview: TextureRect = (
	get_node(
		(
			"CharacterSelectOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/PreviewRow/PreviewPanel/PreviewMargin/CharacterPreview"
		)
	)
	as TextureRect
)
@onready var character_detail_label: Label = (
	get_node(
		(
			"CharacterSelectOverlay/CenterContainer/PanelContainer/"
			+ "MarginContainer/VBox/PreviewRow/DetailLabel"
		)
	)
	as Label
)
@onready var settings_button: BaseButton = $SettingsButton
@onready var settings_overlay: ColorRect = $SettingsOverlay
@onready var settings_panel: PanelContainer = (
	$SettingsOverlay/CenterContainer/PanelContainer as PanelContainer
)
@onready var settings_title_label: Label = (
	get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/TitleLabel") as Label
)
@onready var resolution_option: OptionButton = (
	get_node(
		(
			"SettingsOverlay/CenterContainer/PanelContainer/"
			+ "SettingsContent/ResolutionRow/ResolutionOption"
		)
	)
	as OptionButton
)
@onready var music_volume_slider: HSlider = (
	get_node(
		"SettingsOverlay/CenterContainer/PanelContainer/" + "SettingsContent/MusicVolumeRow/Slider"
	)
	as HSlider
)
@onready var music_volume_value_label: Label = (
	get_node(
		(
			"SettingsOverlay/CenterContainer/PanelContainer/"
			+ "SettingsContent/MusicVolumeRow/ValueLabel"
		)
	)
	as Label
)
@onready var sound_volume_slider: HSlider = (
	get_node(
		"SettingsOverlay/CenterContainer/PanelContainer/" + "SettingsContent/SoundVolumeRow/Slider"
	)
	as HSlider
)
@onready var sound_volume_value_label: Label = (
	get_node(
		(
			"SettingsOverlay/CenterContainer/PanelContainer/"
			+ "SettingsContent/SoundVolumeRow/ValueLabel"
		)
	)
	as Label
)
@onready var mute_all_checkbox: CheckBox = (
	get_node(
		"SettingsOverlay/CenterContainer/PanelContainer/" + "SettingsContent/MuteRow/MuteCheckBox"
	)
	as CheckBox
)
@onready var settings_apply_button: Button = (
	get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/ApplyButton") as Button
)
@onready var settings_close_button: Button = (
	get_node("SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/CloseButton") as Button
)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_upgrade_buttons = [upgrade_button_1, upgrade_button_2, upgrade_button_3]
	_shop_cards = [shop_card_1, shop_card_2, shop_card_3, shop_card_4, shop_card_5]
	_weapon_belt = WeaponBeltScript.new()
	add_child(_weapon_belt)
	_apply_reference_layout()
	_apply_hud_theme()
	overlay.visible = false
	level_up_overlay.visible = false
	shop_overlay.visible = false
	character_select_overlay.visible = false
	settings_overlay.visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	resolution_option.item_selected.connect(_on_resolution_selected)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sound_volume_slider.value_changed.connect(_on_sound_volume_changed)
	mute_all_checkbox.toggled.connect(_on_mute_all_toggled)
	settings_apply_button.pressed.connect(_hide_settings)
	settings_close_button.pressed.connect(_hide_settings)
	_populate_resolution_options()
	shop_reroll_button.pressed.connect(_on_shop_reroll_pressed)
	shop_continue_button.pressed.connect(_on_shop_continue_pressed)
	for index in _upgrade_buttons.size():
		_upgrade_buttons[index].pressed.connect(_on_upgrade_button_pressed.bind(index))
	for index in _shop_cards.size():
		_shop_cards[index].pressed.connect(_on_shop_button_pressed.bind(index))

	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.wave_time_changed.connect(_on_wave_time_changed)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.xp_changed.connect(_on_xp_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.wave_index_changed.connect(_on_wave_index_changed)
	get_viewport().size_changed.connect(_apply_reference_layout)


func _apply_reference_layout() -> void:
	ReferenceHudLayoutScript.apply(
		get_viewport().get_visible_rect().size,
		hud_panel,
		settings_button,
		grease_counter,
		xp_panel,
		_weapon_belt,
		shop_panel,
		shop_grid,
		_shop_cards
	)


func _apply_hud_theme() -> void:
	HudThemeScript.apply_game_ui_theme(self)


func _on_restart_pressed() -> void:
	var tree := get_tree()
	if tree == null:
		return

	tree.paused = false
	tree.reload_current_scene()


func _on_settings_button_pressed() -> void:
	if _is_modal_overlay_open():
		return

	_show_settings()


func _show_settings() -> void:
	_settings_paused_tree = not get_tree().paused
	if _settings_paused_tree:
		get_tree().paused = true

	settings_overlay.visible = true
	_refresh_settings()
	resolution_option.grab_focus()


func _hide_settings() -> void:
	settings_overlay.visible = false
	if _settings_paused_tree:
		get_tree().paused = false
	_settings_paused_tree = false


func _on_resolution_selected(index: int) -> void:
	PerformanceSettings.set_resolution_index(index)
	_refresh_settings()


func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value / 100.0)
	_refresh_settings_labels()


func _on_sound_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value / 100.0)
	_refresh_settings_labels()


func _on_mute_all_toggled(enabled: bool) -> void:
	AudioManager.set_mute_all(enabled)


func _populate_resolution_options() -> void:
	resolution_option.clear()
	for option in PerformanceSettings.get_resolution_options():
		resolution_option.add_item(str(option.get("label", "1920 x 1080")))


func _refresh_settings() -> void:
	if resolution_option.item_count != PerformanceSettings.get_resolution_options().size():
		_populate_resolution_options()
	resolution_option.select(PerformanceSettings.resolution_index)
	music_volume_slider.value = roundi(AudioManager.music_volume * 100.0)
	sound_volume_slider.value = roundi(AudioManager.sfx_volume * 100.0)
	mute_all_checkbox.button_pressed = AudioManager.mute_all
	_refresh_settings_labels()


func _refresh_settings_labels() -> void:
	music_volume_value_label.text = "%d%%" % roundi(AudioManager.music_volume * 100.0)
	sound_volume_value_label.text = "%d%%" % roundi(AudioManager.sfx_volume * 100.0)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed() or event.echo:
		return

	if _handle_overlay_keyboard(event as InputEventKey):
		_mark_input_handled()


func _handle_overlay_keyboard(event: InputEventKey) -> bool:
	var handled := false
	if settings_overlay.visible:
		handled = _handle_settings_keyboard(event)
	elif _is_settings_toggle(event) and not _is_modal_overlay_open():
		_show_settings()
		handled = true
	elif level_up_overlay.visible:
		handled = _handle_level_up_keyboard(event)
	elif shop_overlay.visible:
		handled = _handle_shop_keyboard(event)
	elif character_select_overlay.visible:
		handled = _handle_character_select_keyboard(event)
	elif (
		overlay.visible
		and (event.is_action_pressed("restart") or event.is_action_pressed("ui_accept"))
	):
		_on_restart_pressed()
		handled = true

	return handled


func _is_settings_toggle(event: InputEventKey) -> bool:
	return event.keycode == KEY_ESCAPE


func _is_modal_overlay_open() -> bool:
	return (
		level_up_overlay.visible
		or shop_overlay.visible
		or character_select_overlay.visible
		or overlay.visible
	)


func _handle_settings_keyboard(event: InputEventKey) -> bool:
	if _is_settings_toggle(event):
		_hide_settings()
		return true

	if event.is_action_pressed("ui_accept") and settings_close_button.has_focus():
		_hide_settings()
		return true

	return false


func _mark_input_handled() -> void:
	var viewport := get_viewport()
	if viewport:
		viewport.set_input_as_handled()


func _handle_level_up_keyboard(event: InputEventKey) -> bool:
	var index := _number_key_index(event, 3)
	if index >= 0 and index < _upgrade_choices.size():
		_on_upgrade_button_pressed(index)
		return true

	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_navigate_button_focus(_upgrade_buttons, -1)
		return true

	if event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		_navigate_button_focus(_upgrade_buttons, 1)
		return true

	if event.is_action_pressed("ui_accept"):
		var focused_index := _focused_button_index(_upgrade_buttons)
		if focused_index >= 0:
			_on_upgrade_button_pressed(focused_index)
			return true

	return false


func _handle_character_select_keyboard(event: InputEventKey) -> bool:
	var index := _number_key_index(event, 9)
	if index >= 0 and index < _character_choices.size():
		_on_character_button_pressed(index)
		return true

	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_navigate_button_focus(_character_buttons, -1)
		_update_character_detail_from_focus()
		return true

	if event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		_navigate_button_focus(_character_buttons, 1)
		_update_character_detail_from_focus()
		return true

	if event.is_action_pressed("ui_accept"):
		var focused_index := _focused_button_index(_character_buttons)
		if focused_index >= 0:
			_on_character_button_pressed(focused_index)
			return true

	return false


func _handle_shop_keyboard(event: InputEventKey) -> bool:
	var index := _number_key_index(event, 5)
	if index >= 0:
		return _try_press_shop_button(index)

	var handled := false
	if event.keycode == KEY_R:
		_on_shop_reroll_pressed()
		handled = true
	elif event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_navigate_shop_grid(-1)
		handled = true
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		_navigate_shop_grid(1)
		handled = true
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		_navigate_shop_grid_horizontal(-1)
		handled = true
	elif event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		_navigate_shop_grid_horizontal(1)
		handled = true
	elif event.is_action_pressed("ui_accept"):
		_handle_shop_accept()
		handled = true

	return handled


func _navigate_shop_grid(row_direction: int) -> void:
	var columns := maxi(shop_grid.columns, 1)
	var current := _focused_button_index(_shop_cards)
	if current < 0:
		_focus_first_visible_button(_shop_cards)
		return

	var next := current + row_direction * columns
	while next >= 0 and next < _shop_cards.size():
		var card: Button = _shop_cards[next]
		if card.visible and not card.disabled:
			card.grab_focus()
			return
		next += row_direction * columns


func _navigate_shop_grid_horizontal(column_direction: int) -> void:
	var current := _focused_button_index(_shop_cards)
	if current < 0:
		_focus_first_visible_button(_shop_cards)
		return

	var next := current + column_direction
	while next >= 0 and next < _shop_cards.size():
		var card: Button = _shop_cards[next]
		if card.visible and not card.disabled:
			card.grab_focus()
			return
		next += column_direction


func _try_press_shop_button(index: int) -> bool:
	if index >= _shop_upgrades.size():
		return false
	if _is_shop_slot_sold(index):
		return false

	var card: Button = _shop_cards[index]
	if not card.visible or card.disabled:
		return false

	_on_shop_button_pressed(index)
	return true


func _handle_shop_accept() -> void:
	if shop_reroll_button.has_focus():
		_on_shop_reroll_pressed()
		return

	if shop_continue_button.has_focus():
		_on_shop_continue_pressed()
		return

	var focused_index := _focused_button_index(_shop_cards)
	if focused_index >= 0 and _try_press_shop_button(focused_index):
		return

	_on_shop_continue_pressed()


func _navigate_button_focus(buttons: Array[Button], direction: int) -> void:
	var current := _focused_button_index(buttons)
	if current < 0:
		_focus_first_visible_button(buttons)
		return

	var next := current + direction
	while next >= 0 and next < buttons.size():
		var button := buttons[next]
		if button.visible and not button.disabled:
			button.grab_focus()
			return
		next += direction


func _focused_button_index(buttons: Array[Button]) -> int:
	for index in buttons.size():
		if buttons[index].has_focus():
			return index
	return -1


func _number_key_index(event: InputEventKey, max_keys: int = 8) -> int:
	var number_keys := [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]
	var keypad_keys := [
		KEY_KP_1,
		KEY_KP_2,
		KEY_KP_3,
		KEY_KP_4,
		KEY_KP_5,
		KEY_KP_6,
		KEY_KP_7,
		KEY_KP_8,
		KEY_KP_9,
	]
	var index := number_keys.find(event.keycode)
	if index < 0:
		index = keypad_keys.find(event.keycode)
	if index >= max_keys:
		return -1
	return index


func _on_player_health_changed(current: int, maximum: int) -> void:
	hp_bar.set_value_smooth(float(current), float(maximum))
	hp_value_label.text = "%d / %d" % [current, maximum]

	var ratio := float(current) / float(maxi(maximum, 1))
	hp_bar.set_fill_color(COLOR_BAR_FILL.lerp(COLOR_BAR_FILL_LOW, 1.0 - ratio))


func _on_xp_changed(current: int, to_next: int, level: int) -> void:
	xp_bar.set_value_smooth(float(current), float(maxi(to_next, 1)))
	level_label.text = "XP   %d / %d      LVL %d" % [current, maxi(to_next, 1), level]


func _on_level_up(_level: int) -> void:
	if _xp_flash_tween:
		_xp_flash_tween.kill()
	xp_bar.set_fill_color(COLOR_XP_FLASH)
	_xp_flash_tween = create_tween()
	_xp_flash_tween.tween_property(xp_bar, "modulate", Color(1.4, 1.4, 1.4, 1.0), 0.08)
	_xp_flash_tween.tween_property(xp_bar, "modulate", Color.WHITE, 0.25)
	_xp_flash_tween.tween_callback(func() -> void: xp_bar.set_fill_color(COLOR_XP_FILL))


func _on_wave_time_changed(seconds_remaining: float) -> void:
	var seconds := ceili(maxf(seconds_remaining, 0.0))
	var minutes := seconds / 60
	var seconds_part := seconds % 60
	timer_label.text = "WAVE %02d      %02d:%02d" % [_current_wave, minutes, seconds_part]

	var urgent := seconds <= 10
	timer_label.add_theme_color_override(
		"font_color", Color(0.95, 0.55, 0.35, 1.0) if urgent else COLOR_TEXT
	)
	_update_timer_pulse(urgent)


func _update_timer_pulse(urgent: bool) -> void:
	if not urgent:
		if _timer_pulse_tween:
			_timer_pulse_tween.kill()
			_timer_pulse_tween = null
		timer_label.scale = Vector2.ONE
		return

	if _timer_pulse_tween:
		return

	_timer_pulse_tween = create_tween().set_loops()
	_timer_pulse_tween.tween_property(timer_label, "scale", Vector2(1.08, 1.08), 0.35)
	_timer_pulse_tween.tween_property(timer_label, "scale", Vector2.ONE, 0.35)


func _on_enemy_killed(_enemy: Node, _killer: Node) -> void:
	_kills += 1
	kill_label.text = "KILLS  %d" % _kills


func _on_gold_changed(gold: int) -> void:
	_current_gold = gold
	gold_label.text = CompactNumberFormat.format(gold)


func _on_wave_index_changed(wave: int) -> void:
	_current_wave = wave
	shop_title_label.text = "WAVE %d CLEAR - KITCHEN SHOP" % wave


func show_wave_complete() -> void:
	overlay.visible = true
	overlay_label.text = "Wave Complete!"
	restart_hint.text = "Press R to play again"
	restart_hint.visible = true
	restart_button.visible = true


func show_game_over() -> void:
	overlay.visible = true
	overlay_label.text = "Game Over"
	restart_hint.text = "Press R or Enter to restart"
	restart_hint.visible = true
	restart_button.visible = true
	restart_button.grab_focus()


func show_level_up_options(upgrades: Array[Resource]) -> void:
	_upgrade_choices = upgrades
	level_up_overlay.visible = true
	level_up_title_label.text = "LEVEL UP!"
	level_up_hint_label.text = "W/S navigate  |  1/2/3 or Enter pick  |  Click to choose"
	AudioManager.duck_music()

	for index in _upgrade_buttons.size():
		var button := _upgrade_buttons[index]
		var has_choice := index < _upgrade_choices.size()
		button.visible = has_choice
		button.disabled = not has_choice
		if has_choice:
			var upgrade: Resource = _upgrade_choices[index]
			button.text = UpgradeDisplay.format_card_text(upgrade, "[%d]" % (index + 1))
			UpgradeDisplay.apply_card_style(button, upgrade)

	_focus_first_visible_button(_upgrade_buttons)


func hide_level_up_options() -> void:
	level_up_overlay.visible = false
	_upgrade_choices.clear()
	AudioManager.unduck_music()


func show_shop(
	offers: Array[Resource], gold: int, sold_slots: Array[bool] = [], reroll_cost: int = 0
) -> void:
	_shop_upgrades = offers
	_shop_sold_slots = sold_slots
	_current_gold = gold
	_current_reroll_cost = reroll_cost
	shop_overlay.modulate = Color.WHITE
	shop_panel.modulate = Color.WHITE
	shop_panel.scale = Vector2.ONE
	shop_overlay.visible = true
	shop_hint_label.text = SHOP_HINT_TEXT_FIXED
	_update_shop_buttons()
	shop_continue_button.grab_focus()


func show_shop_transition(
	offers: Array[Resource], gold: int, sold_slots: Array[bool] = [], reroll_cost: int = 0
) -> void:
	_shop_upgrades = offers
	_shop_sold_slots = sold_slots
	_current_gold = gold
	_current_reroll_cost = reroll_cost
	shop_hint_label.text = SHOP_HINT_TEXT_FIXED
	_update_shop_buttons()

	shop_overlay.visible = true
	shop_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	shop_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	shop_panel.scale = Vector2(0.96, 0.96)

	AudioManager.duck_music(SHOP_TRANSITION_DURATION)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(shop_overlay, "modulate:a", 1.0, SHOP_TRANSITION_DURATION)
	tween.parallel().tween_property(shop_panel, "modulate:a", 1.0, SHOP_TRANSITION_DURATION)
	var scale_tween := tween.parallel().tween_property(
		shop_panel, "scale", Vector2.ONE, SHOP_TRANSITION_DURATION
	)
	scale_tween.set_ease(Tween.EASE_OUT)
	await tween.finished
	shop_continue_button.grab_focus()


func refresh_shop(
	offers: Array[Resource], gold: int, sold_slots: Array[bool] = [], reroll_cost: int = 0
) -> void:
	_shop_upgrades = offers
	_shop_sold_slots = sold_slots
	_current_gold = gold
	_current_reroll_cost = reroll_cost
	_update_shop_buttons()


func update_shop_gold(gold: int) -> void:
	_current_gold = gold
	_update_shop_buttons()


func update_weapon_loadout(weapons: Array[WeaponDefinition]) -> void:
	if _weapon_belt:
		_weapon_belt.update_loadout(weapons)


func hide_shop() -> void:
	shop_overlay.visible = false
	shop_overlay.modulate = Color.WHITE
	shop_panel.modulate = Color.WHITE
	shop_panel.scale = Vector2.ONE
	_shop_upgrades.clear()
	_shop_sold_slots.clear()
	AudioManager.unduck_music(0.2)


func request_character_selection(characters: Array[CharacterDefinition]) -> CharacterDefinition:
	_character_choices = characters
	_build_character_buttons(characters)
	character_select_overlay.visible = true
	character_detail_label.text = "Pick a kitchen creature to start your run."
	_clear_character_preview()
	_focus_first_visible_button(_character_buttons)
	_update_character_detail_from_focus()
	return await character_selected


func hide_character_select() -> void:
	character_select_overlay.visible = false
	_character_choices.clear()
	_clear_character_preview()
	for button in _character_buttons:
		button.queue_free()
	_character_buttons.clear()


func _build_character_buttons(characters: Array[CharacterDefinition]) -> void:
	for button in _character_buttons:
		button.queue_free()
	_character_buttons.clear()

	for child in character_grid.get_children():
		child.queue_free()

	for index in characters.size():
		var character := characters[index]
		var button := Button.new()
		button.custom_minimum_size = Vector2(220, 72)
		button.text = "[%d] %s" % [index + 1, character.display_name]
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_on_character_button_pressed.bind(index))
		button.focus_entered.connect(_on_character_button_focus.bind(index))
		button.mouse_entered.connect(_on_character_button_focus.bind(index))
		button.add_theme_font_size_override("font_size", 17)
		character_grid.add_child(button)
		_character_buttons.append(button)


func _on_character_button_focus(index: int) -> void:
	if index < 0 or index >= _character_choices.size():
		return

	var character := _character_choices[index]
	character_detail_label.text = _format_character_detail(character)
	_update_character_preview(character)


func _update_character_preview(character: CharacterDefinition) -> void:
	if character == null or character.sprite == null:
		_clear_character_preview()
		return

	character_preview.texture = character.sprite
	character_preview.modulate = Color.WHITE


func _clear_character_preview() -> void:
	character_preview.texture = null
	character_preview.modulate = Color(1.0, 1.0, 1.0, 0.35)


func _update_character_detail_from_focus() -> void:
	var focused_index := _focused_button_index(_character_buttons)
	if focused_index >= 0:
		_on_character_button_focus(focused_index)


func _format_character_detail(character: CharacterDefinition) -> String:
	var weapon_name := (
		character.starting_weapon.display_name
		if character.starting_weapon and not character.starting_weapon.display_name.is_empty()
		else character.starting_weapon.id if character.starting_weapon else "none"
	)
	return (
		"%s - %s\nHP %d  |  Speed %.0f  |  Luck %d  |  Starts with %s"
		% [
			character.display_name,
			character.description,
			character.max_health,
			character.move_speed,
			character.luck,
			weapon_name,
		]
	)


func _on_character_button_pressed(index: int) -> void:
	if index < 0 or index >= _character_choices.size():
		return

	var selected := _character_choices[index]
	hide_character_select()
	character_selected.emit(selected)


func _update_shop_buttons() -> void:
	shop_gold_label.text = ("GREASE  %d" % _current_gold)
	shop_reroll_cost_label.text = (
		"REROLL COST  %s"
		% ShopDisplay.format_price(_current_reroll_cost, _current_gold >= _current_reroll_cost)
	)
	shop_reroll_button.disabled = _current_reroll_cost > _current_gold

	for index in _shop_cards.size():
		var card: Button = _shop_cards[index]
		var offer: Resource = _shop_upgrades[index] if index < _shop_upgrades.size() else null
		(card as ShopCard).configure(offer, index, _current_gold, _is_shop_slot_sold(index))


func _is_shop_slot_sold(index: int) -> bool:
	return index >= 0 and index < _shop_sold_slots.size() and _shop_sold_slots[index]


func _on_shop_button_pressed(index: int) -> void:
	if index < 0 or index >= _shop_upgrades.size():
		return
	if _is_shop_slot_sold(index):
		return

	shop_purchase_requested.emit(_shop_upgrades[index])


func _on_shop_reroll_pressed() -> void:
	shop_reroll_requested.emit()


func _on_shop_continue_pressed() -> void:
	shop_continue_requested.emit()


func _on_upgrade_button_pressed(index: int) -> void:
	if index < 0 or index >= _upgrade_choices.size():
		return

	upgrade_selected.emit(_upgrade_choices[index])


func _focus_first_visible_button(buttons: Array[Button]) -> void:
	for button in buttons:
		if button.visible and not button.disabled:
			button.grab_focus()
			return
