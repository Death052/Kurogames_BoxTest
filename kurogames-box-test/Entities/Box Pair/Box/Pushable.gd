class_name Pushable
extends RigidBody2D

@export var push_force : float = 200
@export var push_mass : float = 1.0

# reference the player
var player: Player
# reference the sprite of the pushable object
var sprite : Sprite2D

func _ready() -> void:
	# set up rigidbody collision properties
	contact_monitor = true
	max_contacts_reported = 4
	mass = push_mass
	gravity_scale = 0.0
	
	# check if the player exists
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		push_error("%s could not find a Player." % name)
		
	# get the sprite of the pushable object
	for child in get_children():
		if child is Sprite2D:
			sprite = child

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	# alter the ordering layer of the pushable object based on player y world axis
	z_index = 1 if player.global_position.y < global_position.y else -1


# Obtain the push speed of the player. The player push speed is affected by the object's mass
func get_push_speed(player_speed: float, player_mass: float) -> float:
	return player_speed / (1.0 + push_mass / player_mass)
# Box movement when being pushed
func push(push_direction: Vector2, speed: float) -> void:
	linear_velocity = push_direction * speed
# Stop movement when the player stops pushing it
func stop_pushing() -> void:
	linear_velocity = Vector2.ZERO
