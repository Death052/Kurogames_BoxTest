extends Button

@export var scene_path : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
# when button is pressed, transition to level
func _on_pressed() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	TransitionUi.slide_in(0.5)
	
	get_tree().change_scene_to_file(scene_path)
