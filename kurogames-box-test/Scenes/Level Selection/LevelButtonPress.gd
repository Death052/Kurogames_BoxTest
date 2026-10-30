extends Button

@export var scene_path : String
@export var level_num : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# if level is completed, change colour of button
	if GameManager.level_completion[level_num] == true:
		self_modulate = Color.GREEN
	
	pressed.connect(_on_pressed)
	
	
# when button is pressed, transition to level
func _on_pressed() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_in(0.5)
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(scene_path)
