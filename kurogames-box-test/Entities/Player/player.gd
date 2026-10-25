extends CharacterBody2D
@export var movementSpeed: float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _physics_process(delta: float) -> void:
	# Get movement input
	var input := Vector2.ZERO
	input.x = Input.get_axis("MoveLeft", "MoveRight")
	input.y = Input.get_axis("MoveUp", "MoveDown")
	
	# Normalize vector so diagonal movement isn't faster
	input = input.normalized()
	
	# Apply velocity and move
	velocity = input * movementSpeed
	move_and_slide()
