extends Node
class_name GoalBoxPair

@export var box_pair_resource : BoxPair

# signals to indicate state of boxes
signal box_reached
signal box_left

# for checking state of box
var box_pair_is_reached : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set box texture  based on resource
	var box_texture : Texture2D = box_pair_resource.box_texture
	var box_sprite : Sprite2D = self.get_node("Box/Sprite2D")
	box_sprite.texture = box_texture
	
	# set box goal texture based on resource
	var pressure_plate_texture : Texture2D = box_pair_resource.pressure_plate_texture
	var pressure_plate_sprite : Sprite2D = self.get_node("BoxGoal/Sprite2D")
	pressure_plate_sprite.texture = pressure_plate_texture
	
# called when the box is at the box goal
func box_in_place():
	box_pair_is_reached = true
	box_reached.emit()

# called when the box left the box goal
func box_not_in_place():
	box_pair_is_reached = false
	box_left.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
