extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_out(0.5)
	#set_box_masses()

## set all box masses that the player isn't moving to 1000
#func set_box_masses(current_pushable : Pushable) -> void:
	#var pushable_objects = get_tree().get_nodes_in_group("Box")
	#for push_obj in pushable_objects:
		## all pushable objects are rb2d
		#if push_obj is RigidBody2D:
			## make sure the object being changed mass isn't the pushing object
			#if current_pushable != push_obj:
				#var rb2d : RigidBody2D = push_obj
				#rb2d.mass = 1000
				#pass
	
#current_pushable : Pushable

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
