@tool
extends Button

@onready var output_text_edit = $"../Input/CodeOutput/OutputTextEdit"
@onready var input_text_edit = $"../Input/InputTextEdit"

# Load replacements from a JSON file
var replacements = {}

func _ready():
	load_replacements()

func load_replacements():
	var file = FileAccess.open("res://addons/updater/replacement_list.json", FileAccess.READ)
	if file:
		var data = file.get_as_text()
		var json_data = JSON.parse_string(data)
		if json_data:
			replacements = json_data
		else:
			print("Error parsing JSON: ", json_data)
		file.close()
	else:
		print("Failed to open JSON file.")

func _enter_tree():
	pressed.connect(_on_correction_button_pressed)

func _on_correction_button_pressed():
	# Get the text from the input TextEdit
	var input_text = input_text_edit.text
	
	# Perform the replacements for methods and properties
	input_text = perform_replacements(input_text)
	
	# Update signal connection and emission syntax
	input_text = update_signal_syntax(input_text)
	input_text = update_signal_emission_syntax(input_text)
	input_text = update_signal_connection_with_params(input_text)
	
	# Update yield to await for timers
	input_text = update_yield_to_await(input_text)
	
	# Update move_and_slide()
	input_text = update_move_and_slide(input_text)
	
	# Update File.open()
	input_text = update_file_open_syntax(input_text)
	
	# Clear var velocity
	input_text = clear_var_velocity(input_text)
	
	# Set the corrected text in the output TextEdit
	output_text_edit.text = input_text

func perform_replacements(text):
	for key in replacements.keys():
		var pattern = '\\b' + key + '\\b'  
		var regex = RegEx.new()
		regex.compile(pattern)
		while regex.search(text):
			text = regex.sub(text, replacements[key])
	return text

func update_yield_to_await(text):
	var regex = RegEx.new()
	# Match yield for signal connections with parameters
	regex.compile('yield\\(([^,]+), "([^"]+)"\\)')
	text = regex.sub(text, 'await $1.$2')
	# Handle cases with parameters
	regex.compile('yield\\(([^,]+), "([^"]+)", \\[(.+)\\]\\)')
	text = regex.sub(text, 'await $1.$2.bind($3)')
	return text

func update_signal_syntax(text):
	var regex = RegEx.new()
	regex.compile('connect\\("([\\w]+)", self, "([_\\w]+)"\\)')
	return regex.sub(text, '$1.connect($2)')

func update_signal_emission_syntax(text):
	var regex = RegEx.new()
	regex.compile('emit_signal\\("([\\w]+)"\\)')
	text = regex.sub(text, '$1.emit()')
	regex.compile('emit_signal\\("([\\w]+)",\\s*(.+)\\)')
	text = regex.sub(text, '$1.emit($2)')
	return text

func update_signal_connection_with_params(text):
	var regex = RegEx.new()
	regex.compile('connect\\("([\\w]+)", self, "([_\\w]+)",\\s*\\[(.+)\\]\\)')
	return regex.sub(text, '$1.$2.connect($2.bind($3))')


func update_move_and_slide(text):
	var regex = RegEx.new()
	# Match move_and_slide with any parameters and replace with parameter-less call
	regex.compile('move_and_slide\\(.*\\)')
	return regex.sub(text, 'move_and_slide()')


func update_file_open_syntax(text):
	var regex = RegEx.new()
	# Match File.new() and replace with a commented guide
	regex.compile('var\\s+file\\s*=\\s*File\\.new\\(\\)')
	var replacement_text = """\
# var file = FileAccess.open("file_path", FileAccess.READ)
# if file:
#     var data = file.get_as_text()
#     var json_data = JSON.parse_string(data)
#     if json_data:
#         return json_data
#     else:
#         print("Error parsing JSON: ", json_data)
#     file.close()
# else:
#     print("Failed to open JSON file.")
"""
	return regex.sub(text, replacement_text)


func clear_var_velocity(text):
	var regex = RegEx.new()
	# Match lines declaring var velocity and replace with an empty string
	regex.compile('^\\s*var\\s+velocity\\s*=.*$')
	return regex.sub(text, '')
