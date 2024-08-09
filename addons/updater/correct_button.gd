### correct_button.gd

@tool
extends Button

@onready var output_text_edit = $"../Input/CodeOutput/OutputTextEdit"
@onready var input_text_edit = $"../Input/InputTextEdit"

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

func apply_all_transformations(text):
	text = update_signal_syntax(text)
	text = update_signal_emission_syntax(text)
	text = update_signal_emission_with_params(text)
	text = update_signal_connection_with_params(text)
	text = update_yield_to_await(text)
	text = transform_yield_to_await_no_params(text)
	text = update_move_and_slide(text)
	text = update_file_open_syntax(text)
	text = perform_replacements(text)
	return text

func _on_correction_button_pressed():
	var input_text = input_text_edit.text
	print("Original Text:\n", input_text)
	
	input_text = apply_all_transformations(input_text)
	
	output_text_edit.text = input_text
	print("Final Transformed Text:\n", input_text)

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
	regex.compile('yield\\s*\\(\\s*(get_tree\\(\\)\\.create_timer\\(\\s*(\\d+\\.?\\d*)\\s*\\))\\s*,\\s*"timeout"\\s*\\)')
	text = regex.sub(text, 'await $1.$2()')
	return text

func transform_yield_to_await_no_params(text):
	var regex = RegEx.new()
	regex.compile('yield\\(\\s*(\\$?\\w+)\\s*,\\s*"([^"]+)"\\s*\\)')
	return regex.sub(text, 'await $1.$2()')
	
func update_signal_syntax(text):
	var regex = RegEx.new()
	regex.compile('connect\\s*\\(\\s*"([\\w]+)"\\s*,\\s*self\\s*,\\s*"([_\\w]+)"\\s*\\)')
	return regex.sub(text, '$1.connect($2)')

func update_signal_emission_syntax(text):
	var regex = RegEx.new()
	regex.compile('emit_signal\\s*\\(\\s*"([\\w]+)"\\s*(,\\s*.+?)?\\s*\\)')
	return regex.sub(text, '$1.emit()')
	
func update_signal_emission_with_params(text):
	var regex = RegEx.new()
	regex.compile('emit_signal\\s*\\(\\s*"([\\w]+)"\\s*,\\s*([^)]+?)\\s*\\)')
	return regex.sub(text, '$1.emit($2)')


func update_file_open_syntax(text):
	var regex = RegEx.new()
	regex.compile('var\\s+file\\s*=\\s*File\\.new\\(\\)\\s*')
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

func update_signal_connection_with_params(text):
	var regex = RegEx.new()
	regex.compile('connect\\s*\\(\\s*"([\\w]+)"\\s*,\\s*self\\s*,\\s*"([_\\w]+)"\\s*,\\s*\\[(.+)\\]\\s*\\)')
	return regex.sub(text, '$1.$2.connect($2.bind($3))')

func update_move_and_slide(text):
	var regex = RegEx.new()
	regex.compile('move_and_slide\\s*\\(.*\\)')
	return regex.sub(text, 'move_and_slide()')

