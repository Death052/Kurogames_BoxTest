extends Button

const SAVED_LEVELS_PATH := "res://Scenes/Custom Level/Saved_Levels"

@export var editor_level_path: String
@export var custom_level_path : String

@onready var full_panel : PanelContainer = $"../../../../SavedLevelsPanel"
@onready var level_list: VBoxContainer = $"../../../../SavedLevelsPanel/Content/ScrollContainer/LevelList"
@onready var level_row_template: HBoxContainer = $"../../../../SavedLevelsPanel/Content/ScrollContainer/LevelList/LevelRow"
@onready var back_btn : Button = $"../../../../SavedLevelsPanel/Content/CenterContainer/Back"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect the editor button to the show panel function
	pressed.connect(show_panel)
	back_btn.pressed.connect(remove_panel)
	
	_load_saved_levels()

# show the panel containing the scroll list of custom levels
func show_panel():
	full_panel.visible = true

func remove_panel():
	full_panel.visible = false

# load the available saved json levels and show it into the scroll menu
func _load_saved_levels() -> void:
	level_row_template.visible = false

	var directory := DirAccess.open(SAVED_LEVELS_PATH)
	if directory == null:
		push_error("Could not access saved levels directory: %s" % SAVED_LEVELS_PATH)
		return
		
	var level_paths: Array[String] = []
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		if not directory.current_is_dir() and file_name.to_lower().ends_with(".json"):
			level_paths.append(SAVED_LEVELS_PATH.path_join(file_name))
		file_name = directory.get_next()
	directory.list_dir_end()
	level_paths.sort()

	for level_path in level_paths:
		_add_saved_level_row(level_path)


# add each json level data into entries inside the scroll menu
func _add_saved_level_row(level_path: String) -> void:
	var row := level_row_template.duplicate() as HBoxContainer
	row.name = "LevelRow_%s" % level_path.get_file().get_basename()
	row.visible = true
	level_list.add_child(row)
	# show the name of the named level
	var level_name := row.get_node("Name") as Label
	level_name.text = level_path.get_file().get_basename()
	# connect the buttons to different functions
	var play_button := row.get_node("Play") as Button
	var edit_button := row.get_node("Edit") as Button
	var delete_button := row.get_node("Delete") as Button
	play_button.pressed.connect(_on_saved_level_play_pressed.bind(level_path))
	edit_button.pressed.connect(_on_saved_level_edit_pressed.bind(level_path))
	delete_button.pressed.connect(_on_saved_level_delete_pressed.bind(level_path))

# make sure the player enters custom level with the level data
func _on_saved_level_play_pressed(level_path: String) -> void:
	GameManager.loaded_level_json = level_path
	GameManager.in_editor_test = false
	
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_in(0.5)
	get_tree().change_scene_to_file(custom_level_path)

# make sure the player enters editor with this json data
func _on_saved_level_edit_pressed(level_path: String) -> void:
	GameManager.loaded_level_json = level_path
	GameManager.in_editor_test = true
	
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_in(0.5)
	get_tree().change_scene_to_file(editor_level_path)
	#print("Edit pressed for saved level: %s" % level_path)

# deletes the json level from both the directory and the scrollbar
func _on_saved_level_delete_pressed(level_path: String) -> void:
	var file_name := level_path.get_file()
	var directory := DirAccess.open(SAVED_LEVELS_PATH)
	if directory == null:
		push_error("Could not access saved levels directory: %s" % SAVED_LEVELS_PATH)
		return
	var error := directory.remove(file_name)
	if error != OK:
		push_error("Could not delete saved level %s: %s" % [level_path, error_string(error)])
		return
	var row_name := "LevelRow_%s" % level_path.get_file().get_basename()
	var row := level_list.get_node_or_null(NodePath(row_name))
	if row == null:
		push_warning("Deleted saved level, but its list row was not found: %s" % row_name)
		return
	row.queue_free()
