class_name HUD
extends CanvasLayer
## The in-game heads-up display: timer, health, level and experience bar.
##
## Built entirely in code so it works without any scene files. It listens to
## [SignalBus] for state changes.

var _root: Control
var _timer_label: Label
var _hp_label: Label
var _level_label: Label
var _xp_bar: ProgressBar


func _ready() -> void:
	layer = 5
	_build_ui()
	SignalBus.player_hp_changed.connect(_on_hp_changed)
	SignalBus.xp_changed.connect(_on_xp_changed)
	SignalBus.player_leveled_up.connect(_on_level)
	SignalBus.game_over.connect(_show_banner.bind("Game Over"))
	SignalBus.game_won.connect(_show_banner.bind("You Win!"))


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_timer_label = Label.new()
	_timer_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_timer_label.position.y = 12.0
	_timer_label.add_theme_font_size_override("font_size", 28)
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(_timer_label)

	_hp_label = Label.new()
	_hp_label.position = Vector2(16, 12)
	_hp_label.add_theme_font_size_override("font_size", 18)
	_root.add_child(_hp_label)

	_level_label = Label.new()
	_level_label.position = Vector2(16, 40)
	_level_label.add_theme_font_size_override("font_size", 18)
	_root.add_child(_level_label)

	_xp_bar = ProgressBar.new()
	_xp_bar.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_xp_bar.position = Vector2(0, 60)
	_xp_bar.size = Vector2(400, 10)
	_xp_bar.show_percentage = false
	_root.add_child(_xp_bar)


func _process(_delta: float) -> void:
	if GameManager.is_running and GameManager.stage_data != null:
		var remaining := GameManager.stage_data.duration_seconds - GameManager.elapsed
		_timer_label.text = _format_time(remaining)


func _on_hp_changed(hp: float, max_hp: float) -> void:
	_hp_label.text = "HP %d / %d" % [int(ceil(hp)), int(ceil(max_hp))]


func _on_level(level: int) -> void:
	_level_label.text = "Level %d" % level


func _on_xp_changed(xp: float, xp_to_next: float) -> void:
	_xp_bar.max_value = xp_to_next
	_xp_bar.value = xp


func _show_banner(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 56)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(label)


func _format_time(seconds: float) -> String:
	var s := int(ceil(maxf(0.0, seconds)))
	return "%02d:%02d" % [s / 60, s % 60]
