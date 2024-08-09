# copy_button.gd
@tool
extends Button

@onready var output_text_edit = $"../OutputTextEdit"

func _enter_tree():
	pressed.connect(_on_copy_button_pressed)
	
func _on_copy_button_pressed():
	# Get the text from the input TextEdit
	var copy_text = output_text_edit.text
	# Copy the text to the clipboard
	DisplayServer.clipboard_set(copy_text)
	print("Code copied to clipboard!")
