extends State

var pushed_object : Pushable 
var saved_collision : KinematicCollision2D	

func enter() -> void:
	# determine object being pushed
	for i in actor.get_slide_collision_count():
		var collision := actor.get_slide_collision(i)
		var collider := collision.get_collider()
		# check if collider is a Pushable object
		if collider is Pushable:
			pushed_object = collider
			saved_collision = collision

	if pushed_object == null:
		return

	set_box_masses(pushed_object)
		
	
	# set outline shaders to indicate pushing relation
	ShaderManager.set_outline(actor.player_sprite, Color(1.0, 0.4, 0.331, 1.0))
	ShaderManager.set_outline(pushed_object.sprite,Color(1.0, 0.4, 0.331, 1.0))
	
	# listen to input
	actor.interactionPressed.connect(_leave_pushing)
	

func exit() -> void:
	if actor.interactionPressed.is_connected(_leave_pushing):
		actor.interactionPressed.disconnect(_leave_pushing)
	restore_box_masses()


func physics_update(_delta: float) -> void:
	var push_direction : Vector2 = -saved_collision.get_normal()
	actor.movement_axis_constraint = push_direction
	# get push speed based on pushable object mass
	var push_speed = pushed_object.get_push_speed(
		actor.movementSpeed,
		actor.player_mass
	)
	# lock player movement to only the specific axis
	# Start moving the player and the object only if the player is moving
	if actor.input.dot(push_direction) > 0.1:
		pushed_object.push(push_direction, push_speed)
		actor.push_speed = push_speed
		actor.pushed_object = pushed_object
		actor.in_push_state = true
	else:
		pushed_object.stop_pushing()
	return

func _leave_pushing():
	if actor.in_push_state == true:
		# reset pushing variables before leaving push state
		actor.end_pushing()
		actor.movement_axis_constraint = Vector2.ZERO
		state_machine.transition_to("IdleState")
		# remove shader
		ShaderManager.remove_shader(actor.player_sprite)
		ShaderManager.remove_shader(pushed_object.sprite)


# make every other box have huge mass so that the player can only push
# one box at a time
func set_box_masses(current_pushable: Pushable) -> void:
	for pushable in get_tree().get_nodes_in_group("Box"):
		if pushable is Pushable and pushable != current_pushable:
			pushable.mass = 1000.0

# upon releasing, revert boxes back to its original mass
func restore_box_masses() -> void:
	for pushable in get_tree().get_nodes_in_group("Box"):
		if pushable is Pushable:
			pushable.mass = pushable.push_mass


func determine_push() -> void:
	pass
