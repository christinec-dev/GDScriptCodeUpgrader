### highlighter.gd

@tool
class_name CustomHighlighter
extends CodeHighlighter

var keywords = [
	"if", "elif", "else", "for", "while", "match", "break", "continue", "pass", "return",
	"class", "class_name", "extends", "is", "in", "as", "self", "signal", "func", "static",
	"const", "enum", "var", "breakpoint", "preload", "await", "yield", "assert", "void",
	"PI", "TAU", "INF", "NAN"
]

var member_keywords = [
	"onready", "export", "setget", "preload", "load"
]

func _init():
	# Initialize the highlighter with default keywords and colors
	add_keywords_color(keywords, Color(1.0, 0.294, 0.2))
	add_member_keywords_color(member_keywords, Color(0.3, 0.7, 0.8))

func add_keywords_color(keywords: Array, color: Color):
	for keyword in keywords:
		add_keyword_color(keyword, color)

func add_member_keywords_color(member_keywords: Array, color: Color):
	for member_keyword in member_keywords:
		add_member_keyword_color(member_keyword, color)
