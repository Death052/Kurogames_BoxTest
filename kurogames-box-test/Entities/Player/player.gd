extends CharacterBody2D
class_name Player
# handles movement speed of the character
@export var movementSpeed: float = 100.0
@export var player_mass: float = 10.0
var movement_axis_constraint: Vector2

# sprite component and animation component of player
var player_sprite : Sprite2D
var animation_player : AnimationPlayer
var last_facing_direction : String

# Pushed Object
var pushed_object: Pushable
var pushed_mass : float = 0.0
var push_speed: float = 0.0
var in_push_state : bool

# Player signals
signal interactionPressed

# input
var input : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get Sprite and Animation Player
	player_sprite = get_node("Sprite2D")
	animation_player = get_node("AnimationPlayer")

func _unhandled_input(event: InputEvent) -> void:
	# Check if the event is the action you want
	if event.is_action_pressed("Interact"):
		# other scripts can subscribe to this event
		interactionPressed.emit()
	
# called when the pushable object is detected
func begin_pushing(object: Pushable) -> void:
	pushed_object = object
	push_speed = object.get_push_speed(movementSpeed, player_mass)
	in_push_state = true
	pushed_mass = object.push_mass

func end_pushing() -> void:
	if pushed_object != null:
		pushed_object.stop_pushing()

	pushed_object = null
	push_speed = 0.0
	pushed_mass = 0.0
	in_push_state = false

func _physics_process(delta: float) -> void:
	# Get movement input
	input = Vector2.ZERO
	input.x = Input.get_axis("MoveLeft", "MoveRight")
	input.y = Input.get_axis("MoveUp", "MoveDown")
	# Normalize vector so diagonal movement isn't faster
	input = input.normalized()
	
	# Apply velocity and move
	var current_speed := movementSpeed
	if in_push_state and pushed_object != null:
		# make sure player can only move one way through pushing
		if movement_axis_constraint != Vector2.ZERO:
			if input.dot(movement_axis_constraint) <= 0:
				input = Vector2.ZERO
			else:
				input = movement_axis_constraint * input.length()
		# set new speed when moving
		current_speed = push_speed
	
	# Update the player animation
	update_animations()
	
	# use the calculated velocity to move the player
	velocity = input * current_speed
	move_and_slide()
	
	
# update the animations of the player
func update_animations():
	if input != Vector2.ZERO:
		# Determine if moving horizontally or vertically
		if abs(input.x) > abs(input.y):
			# play side animation if horizontal
			last_facing_direction = "Side"
			if player_sprite != null:
				# Flip sprite if moving left, face right by default
				player_sprite.flip_h = input.x > 0
			animation_player.play("Walk Side")
		else:
			if input.y < 0:
				last_facing_direction = "Up"
				animation_player.play("Walk Up")
			else:
				last_facing_direction = "Down"
				animation_player.play("Walk Down")
		# Play corresponding Walk animation
	else:
		# Play corresponding Idle animation based on last faced direction
		if last_facing_direction == "Side":
			animation_player.play("Idle Side")
		elif last_facing_direction == "Up":
			animation_player.play("Idle Up")
		else:
			animation_player.play("Idle Down")
	
	
