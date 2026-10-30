extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_out(0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
