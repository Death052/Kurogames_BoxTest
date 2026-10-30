extends CanvasLayer

@onready var total_boxes_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/TotalBoxesLabel
@onready var boxes_left_label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/BoxesLeftLabel


func update_box_counts(total_boxes: int, boxes_left: int) -> void:
	total_boxes_label.text = "%d" % total_boxes
	boxes_left_label.text = "%d" % boxes_left
