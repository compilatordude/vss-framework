@tool
extends EditorPlugin
## Installs the VSS Framework autoloads when the plugin is enabled.
##
## Enabling this plugin registers the three framework singletons
## (SignalBus, DataManager, GameManager) so the framework's classes and
## content can run. Disabling it removes them again.

const AUTOLOADS := {
	"SignalBus": "res://addons/vss_framework/autoload/signal_bus.gd",
	"DataManager": "res://addons/vss_framework/autoload/data_manager.gd",
	"GameManager": "res://addons/vss_framework/autoload/game_manager.gd",
}


func _enter_tree() -> void:
	_add_autoloads()


func _exit_tree() -> void:
	_remove_autoloads()


## Registers each singleton unless an autoload with that name already exists.
func _add_autoloads() -> void:
	for singleton_name in AUTOLOADS:
		var setting := "autoload/" + singleton_name
		if not ProjectSettings.has_setting(setting):
			add_autoload_singleton(singleton_name, AUTOLOADS[singleton_name])


## Removes the singletons this plugin owns.
func _remove_autoloads() -> void:
	for singleton_name in AUTOLOADS:
		var setting := "autoload/" + singleton_name
		if ProjectSettings.has_setting(setting):
			remove_autoload_singleton(singleton_name)
