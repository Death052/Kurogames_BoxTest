extends Camera2D

var is_panning := false
# for moving the camera in the editor by holding down right mouse and dragging
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_panning = event.pressed
		return

	if is_panning and event is InputEventMouseMotion:
		position -= event.relative / zoom
