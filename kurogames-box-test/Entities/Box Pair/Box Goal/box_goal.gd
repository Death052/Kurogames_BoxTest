extends Node
# the box that this box goal should detect
@export var box : Box

func _on_body_entered(body: Node2D) -> void:
	if body == box:
		get_parent().box_in_place()

func _on_body_exited(body: Node2D) -> void:
	if body == box:
		get_parent().box_not_in_place()
