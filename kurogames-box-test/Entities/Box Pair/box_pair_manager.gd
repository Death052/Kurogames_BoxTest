@tool
extends Node
class_name GoalBoxPair

@export var box_pair_resource : BoxPair
@export var box_position := Vector2(26, -27):
	set(value):
		box_position = value
		_update_child_positions()
@export var goal_position := Vector2(25, -73):
	set(value):
		goal_position = value
		_update_child_positions()

var box_ani : AnimationPlayer
var box_pres_ani : AnimationPlayer

# signals to indicate state of boxes
signal box_reached
signal box_left

# for checking state of box
var box_pair_is_reached : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_child_positions()

	# set box texture  based on resource
	if box_pair_resource == null:
		return
	
	# get the box animations
	box_ani = self.get_node("Box/AnimationPlayer")
	box_pres_ani = self.get_node("BoxGoal/AnimationPlayer")
	
	var box_texture : Texture2D = box_pair_resource.box_texture
	var box_sprite : Sprite2D = self.get_node("Box/Sprite2D")
	box_sprite.texture = box_texture
	
	# set box goal texture based on resource
	var pressure_plate_texture : Texture2D = box_pair_resource.pressure_plate_texture
	var pressure_plate_sprite : Sprite2D = self.get_node("BoxGoal/Sprite2D")
	pressure_plate_sprite.texture = pressure_plate_texture


func _update_child_positions() -> void:
	if has_node("Box"):
		$Box.position = box_position
	if has_node("BoxGoal"):
		$BoxGoal.position = goal_position
	
# called when the box is at the box goal
func box_in_place():
	# play sound when box is in place
	SoundManager.play_sfx("PressureActivate_SFX")
	box_ani.play("Placed")
	box_pres_ani.play("Pressed")
	box_pair_is_reached = true
	box_reached.emit()

# called when the box left the box goal
func box_not_in_place():
	box_ani.play("Idle")
	box_pres_ani.play("Idle")
	box_pair_is_reached = false
	box_left.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
