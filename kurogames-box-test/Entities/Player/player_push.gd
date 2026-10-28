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
	
	# set outline shaders to indicate pushing relation
	ShaderManager.set_outline(actor.player_sprite, Color(1.0, 0.4, 0.331, 1.0))
	ShaderManager.set_outline(pushed_object.sprite,Color(1.0, 0.4, 0.331, 1.0))
	

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
	print("actor.input.dot(push_direction) = ", actor.input.dot(push_direction))
	if actor.input.dot(push_direction) > 0.1:
		pushed_object.push(push_direction, push_speed)
		actor.push_speed = push_speed
		actor.pushed_object = pushed_object
		actor.in_push_state = true
	else:
		pushed_object.stop_pushing()
	return


func determine_push() -> void:
	pass
