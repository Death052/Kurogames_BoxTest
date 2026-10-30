extends Node

@onready var transition_overlay: TextureRect = $TransitionOverlay
var transition_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().size_changed.connect(_resize_transition_overlay)
	_resize_transition_overlay()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_transition_color(color: Color) -> void:
	transition_overlay.modulate = color


func slide_in(duration: float = 0.5) -> void:
	animate_transition(0.0, duration)
	if transition_tween != null:
		await transition_tween.finished


func slide_out(duration: float = 0.5) -> void:
	if transition_tween != null:
		transition_tween.kill()
		transition_tween = null
	transition_overlay.position.x = 0.0
	transition_overlay.visible = true
	animate_transition(get_viewport().get_visible_rect().size.x, duration)
	if transition_tween != null:
		await transition_tween.finished


func animate_transition(target_x: float, duration: float) -> void:
	transition_overlay.visible = true
	if transition_tween != null:
		transition_tween.kill()
	transition_tween = null

	var start_x := transition_overlay.position.x
	transition_tween = create_tween()
	transition_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	transition_tween.tween_property(transition_overlay, "position:x", target_x, duration)
	if target_x > start_x:
		transition_tween.tween_callback(func() -> void: transition_overlay.visible = false)


func _resize_transition_overlay() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	transition_overlay.size = viewport_size
	if not transition_overlay.visible:
		transition_overlay.position.x = viewport_size.x
