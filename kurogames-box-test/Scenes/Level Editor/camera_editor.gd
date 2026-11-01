extends Camera2D

const ZOOM_STEP := 1.1
const MIN_ZOOM := 0.5
const MAX_ZOOM := 8.0

var is_panning := false
# for moving the camera in the editor by holding down right mouse and dragging
# for zooming the camera, use the scroll input of mouse
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at_mouse(ZOOM_STEP)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at_mouse(1.0 / ZOOM_STEP)
			return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		is_panning = event.pressed
		return

	if is_panning and event is InputEventMouseMotion:
		position -= event.relative / zoom

func _zoom_at_mouse(factor: float) -> void:
	var mouse_position_before := get_global_mouse_position()
	var new_zoom: float = clampf(zoom.x * factor, MIN_ZOOM, MAX_ZOOM)
	zoom = Vector2(new_zoom, new_zoom)
	var mouse_position_after := get_global_mouse_position()
	position += mouse_position_before - mouse_position_after
