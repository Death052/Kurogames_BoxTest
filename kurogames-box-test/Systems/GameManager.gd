extends Node

var current_attempting_level : int
var level_completion : Array[bool] = []

var total_levels_in_game : int = 3

var loaded_level_json : String = ""
var in_editor_test : bool = false

func _ready() -> void:
	# Resize the array to match your total level count
	level_completion.resize(total_levels_in_game)
	# Fill all indices with false
	level_completion.fill(false)
