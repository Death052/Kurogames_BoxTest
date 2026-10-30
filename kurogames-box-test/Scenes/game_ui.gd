extends CanvasLayer

@onready var total_boxes_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/TotalBoxesLabel
@onready var boxes_left_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/BoxesLeftLabel

@onready var back_btn : Button = $ButtonMarginContainer/PanelContainer/MarginContainer/HBoxContainer/Back
@onready var retry_btn : Button = $ButtonMarginContainer/PanelContainer/MarginContainer/HBoxContainer/Retry

func _ready() -> void:
	back_btn.pressed.connect(_on_back_button_pressed)
	retry_btn.pressed.connect(_on_retry_button_pressed)

func _process(_delta: float) -> void:
	# make sure can exclude scenes from showing the game ui 
	var current_scene := get_tree().current_scene
	visible = current_scene == null or not current_scene.get_meta("hide_game_ui", false)


func update_box_counts(total_boxes: int, boxes_left: int) -> void:
	print("total_boxes_label = ", total_boxes_label)
	total_boxes_label.text = "%d" % total_boxes
	boxes_left_label.text = "%d" % boxes_left

func update_box_count_ui(goal_box_pairs_in_scene : Array[GoalBoxPair]) -> void:
	var boxes_left := 0
	for pair in goal_box_pairs_in_scene:
		if not pair.box_pair_is_reached:
			boxes_left += 1
	update_box_counts(goal_box_pairs_in_scene.size(), boxes_left)

func _on_back_button_pressed() -> void:
	# return to level selection
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_in(0.5)
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://Scenes/Level Selection/level_selection_screen.tscn")

func _on_retry_button_pressed() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_in(0.5)
	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()
	
