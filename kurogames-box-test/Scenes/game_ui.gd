extends CanvasLayer

@onready var total_boxes_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/TotalBoxesLabel

@onready var boxes_left_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/BoxesLeftLabel

func _ready() -> void:
	pass

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
