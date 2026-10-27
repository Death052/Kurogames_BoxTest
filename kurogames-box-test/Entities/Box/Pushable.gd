extends RigidBody2D

@export var push_force: float = 200.0
# The player character
var player : Player
# if player is in the collision area make sure player can pick up box any time
var can_pickup : bool = false

# box signals 

func _ready() -> void:
	# find the player in the scene
	player = get_tree().get_first_node_in_group("Player")
	# Ensure contact monitoring is active so we can detect collisions
	contact_monitor = true
	max_contacts_reported = 4
	push_force = player.movementSpeed
	# connect to the player interaction signal
	player.interactionPressed.connect(_pick_up_box)

func _pick_up_box() -> void:
	# check if player is in the area of box
	if can_pickup:
		pass
	pass



func _physics_process(delta: float) -> void:
	# Check all bodies currently colliding with this box
	for body in get_colliding_bodies():
		# If the collider is our player (CharacterBody2D) and they are moving
		if body is CharacterBody2D and body.velocity.length() > 0:
			# Apply a force to the box in the direction the player is moving
			var push_direction = body.velocity.normalized()
			apply_central_force(push_direction * push_force)


func _on_check_player_body_entered(body: Node2D) -> void:
	if body == player:
		can_pickup = true

func _on_check_player_body_exited(body: Node2D) -> void:
	if body == player:
		can_pickup = false
