extends Node
# the box that this box goal should detect
@export var box : Box

func _on_body_entered(body: Node2D) -> void:
	if body == box:
		print("Entered Box Collision Area")
