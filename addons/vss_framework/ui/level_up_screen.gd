class_name LevelUpScreen
extends CanvasLayer
## Presents the level-up choices and forwards the pick to [LevelUpSystem].
##
## Built entirely in code; shows a title and one button per choice.

## The system that applies the chosen reward. Set by the main scene.
var level_up_system: LevelUpSystem

var _root: Control
var _choices_box: VBoxContainer


func _ready() -> void:
	layer = 10
	visible = false
	# Keep processing while the game is paused so the buttons stay clickable.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	SignalBus.level_up_choices_ready.connect(_show_choices)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var panel := VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.add_theme_constant_override("separation", 12)
	_root.add_child(panel)

	var title := Label.new()
	title.text = "Level Up!"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)

	_choices_box = VBoxContainer.new()
	_choices_box.add_theme_constant_override("separation", 10)
	panel.add_child(_choices_box)


func _show_choices(choices: Array) -> void:
	visible = true
	_clear_choices()
	for choice in choices:
		var button := Button.new()
		button.text = "%s\n%s" % [choice.display_name, choice.description]
		button.custom_minimum_size = Vector2(340, 76)
		button.pressed.connect(_on_picked.bind(choice))
		_choices_box.add_child(button)


func _clear_choices() -> void:
	for child in _choices_box.get_children():
		_choices_box.remove_child(child)
		child.queue_free()


func _on_picked(choice: UpgradeChoice) -> void:
	visible = false
	if level_up_system != null:
		level_up_system.apply_choice(choice)
