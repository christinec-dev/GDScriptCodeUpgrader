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
	text = perform_manual_replacements(text)
	text = update_yield_to_await(text)
	text = update_signal_syntax(text)
	text = update_signal_connection_with_params(text)
	text = update_signal_emission_syntax(text)
	text = update_signal_emission_with_params(text)
	text = update_move_and_slide(text)
	text = update_file_open_syntax(text)
	text = update_set_cell_syntax_with_guide(text)
	text = update_cell_size_access(text)
	text = update_tween_instantiation(text)
	text = perform_replacements(text)
	return text

func _on_correction_button_pressed():
	var input_text = input_text_edit.text
	input_text = apply_all_transformations(input_text)
	call_deferred("update_output_text", input_text)

func update_output_text(updated_text):
	output_text_edit.text = updated_text

func perform_replacements(text):
	for key in replacements.keys():
		var pattern = '\\b' + key + '\\b'  
		var regex = RegEx.new()
		regex.compile(pattern)
		while regex.search(text):
			text = regex.sub(text, replacements[key])
	return text

func perform_manual_replacements(text):
	var regex = RegEx.new()
	
	regex.compile("\\bexport\\b")  
	text = regex.sub(text, "@export", true)
	
	regex.compile("\\bonready\\b")  
	text = regex.sub(text, "@onready", true)
	
	return text

func update_yield_to_await(text):
	var regex = RegEx.new()
	#  without any parameters inside create_timer()
	regex.compile('yield\\s*\\(\\s*scene_tree\\.create_timer\\s*,\\s*"timeout"\\s*\\)')
	text = regex.sub(text, 'await get_tree().create_timer(1).timeout()', true)
	# with a specified duration 
	regex.compile('yield\\s*\\(\\s*scene_tree\\.create_timer\\s*\\(([^)]+)\\)\\s*,\\s*"timeout"\\s*\\)')
	text = regex.sub(text, 'await get_tree().create_timer($1).timeout', true)
	#  existing timer variable
	regex.compile('yield\\s*\\(\\s*(\\$?\\w+)\\.create_timer\\((\\d+(\\.\\d+)?)\\)\\s*,\\s*"timeout"\\s*\\)')
	text = regex.sub(text, 'await $1.create_timer($2).timeout()', true)
	#  general variable with a signal
	regex.compile('yield\\s*\\(\\s*(\\$?\\w+)\\s*,\\s*"([^"]+)"\\s*\\)')
	text = regex.sub(text, 'await $1.$2()', true)
	return text

func update_signal_syntax(text):
	var regex = RegEx.new()
	regex.compile('connect\\s*\\(\\s*"([\\w]+)"\\s*,\\s*self\\s*,\\s*"([_\\w]+)"\\s*\\)')
	text = regex.sub(text, '$1.connect($2)', true)
	return text

func update_signal_emission_syntax(text):
	var regex = RegEx.new()
	regex.compile('emit_signal\\s*\\(\\s*"([\\w]+)"\\s*\\)')
	text = regex.sub(text, '$1.emit()')
	return text
	
func update_signal_emission_with_params(text):
	var regex = RegEx.new()
	regex.compile('emit_signal\\s*\\(\\s*"([\\w]+)"\\s*,\\s*(.*?)\\s*\\)')
	var result = regex.search(text)
	while result:
		var signal_name = result.get_string(1)
		var parameter = result.get_string(2)
		var replacement = signal_name + ".emit(" + parameter + ")"
		text = regex.sub(text, replacement)
		result = regex.search(text)
	return text


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
	text = regex.sub(text, replacement_text, true)
	return text

func update_signal_connection_with_params(text):
	var regex = RegEx.new()
	regex.compile('connect\\s*\\(\\s*"([\\w]+)"\\s*,\\s*self\\s*,\\s*"([_\\w]+)"\\s*,\\s*\\[(.+)\\]\\s*\\)')
	return regex.sub(text, '$1.$2.connect($2.bind($3))')

func update_move_and_slide(text):
	var regex = RegEx.new()
	regex.compile('move_and_slide\\s*\\(.*\\)')
	text = regex.sub(text, 'move_and_slide()', true)
	
	regex.compile("\\w+\\s*=\\s*move_and_slide\\(\\s*\\)")
	text = regex.sub(text, "move_and_slide()")
	
	regex.compile("\\w+\\.\\w+\\s*=\\s*move_and_slide\\([^)]+\\)\\.\\w+")
	text = regex.sub(text, "move_and_slide()")
	
	return text

func update_set_cell_syntax_with_guide(text):
	var guide_text = "set_cell()" + "\n" + "# Please replace this  set_cell/set_cell_v call with the new format:\n" + "# set_cell(layer, Vector2i(x, y), source_id, atlas_coords, alternative_tile)\n" + "# Example: set_cell(0, Vector2i(10, 20), -1, Vector2i(-1, -1), 0)"
	var regex = RegEx.new()
	regex.compile('set_cell\\s*\\([^)]*\\)')
	text = regex.sub(text, guide_text, true) 
	regex.compile('set_cell_v\\s*\\([^)]*\\)')
	text = regex.sub(text, guide_text, true) 
	return text

func update_cell_size_access(text):
	var regex = RegEx.new()
	regex.compile('(\\s*)\\.cell_size')
	var replacement_text = '$1.tile_set.tile_size'
	text = regex.sub(text, replacement_text, true) 
	return text

func update_tween_instantiation(text):
	var regex = RegEx.new()
	regex.compile('var\\s+(\\w+)\\s*:\\s*Tween\\s*=\\s*(\\$[\\w/]+)\\s*;?')
	var replacement_text = 'var $1: Tween = Tween.new()' + '\n'
	text = regex.sub(text, replacement_text, true) 
	return text

