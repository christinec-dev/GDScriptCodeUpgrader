### updater.gd

@tool
extends EditorPlugin

var dock

func _enter_tree():
	# Add the dock
	dock = preload("res://addons/updater/updater.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BR, dock)
	
func _exit_tree():
	# Remove the dock
	remove_control_from_docks(dock)
	dock.queue_free()
