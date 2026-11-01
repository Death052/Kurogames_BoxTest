extends Node
class_name BoxGoalSubEditor

@export var main_editor : MainEditor

# Sprite References
@onready var red_box_sprite : Sprite2D = %RedBox
@onready var red_box_goal_sprite : Sprite2D = %RedGoal
@onready var yellow_box_sprite : Sprite2D = %YellowBox
@onready var yellow_box_goal_sprite : Sprite2D = %YellowGoal
@onready var blue_box_sprite : Sprite2D = %BlueBox
@onready var blue_box_goal_sprite : Sprite2D = %BlueGoal

# box and goal related textures
@export var red_box_texture : Texture2D
@export var yellow_box_texture : Texture2D
@export var blue_box_texture : Texture2D
@export var red_box_goal_texture : Texture2D
@export var yellow_box_goal_texture : Texture2D
@export var blue_box_goal_texture : Texture2D

var box : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _place_box_location(colour : String) -> void:
	# disable all buttons and interfaces 
	main_editor.disable_buttons_and_interfaces()
	# make sure player can't press other buttons
	main_editor.disable_all_buttons()
	
	main_editor.selected_others = ""
	# set tilepreview to the box sprite
	if colour == "red":
		main_editor.selected_box = "red"
		main_editor.tile_preview.texture = red_box_texture
		red_box_sprite.texture = null
		red_box_goal_sprite.texture = null
		
	elif colour == "yellow":
		main_editor.selected_box = "yellow"
		main_editor.tile_preview.texture = yellow_box_texture
		yellow_box_sprite.texture = null
		yellow_box_goal_sprite.texture = null
		
	elif colour == "blue":
		main_editor.selected_box = "blue"
		main_editor.tile_preview.texture = blue_box_texture
		blue_box_sprite.texture = null
		blue_box_goal_sprite.texture = null
		
	else:
		return

	main_editor.selected_layer = null
	main_editor.selected_box_colour = colour
	main_editor.tile_preview.visible = true
	main_editor.mode_label.text = "Selected %s box, click the canvas to place it" % colour


func _place_box_at(position: Vector2) -> void:
	var box_sprite: Sprite2D
	match main_editor.selected_box_colour:
		"red":
			red_box_sprite.texture = red_box_texture
			red_box_sprite.position = position
			#box_sprite = red_box_sprite
		"yellow":
			yellow_box_sprite.texture = yellow_box_texture
			yellow_box_sprite.position = position
			#box_sprite = yellow_box_sprite
		"blue":
			blue_box_sprite.texture = blue_box_texture
			blue_box_sprite.position = position
			#box_sprite = blue_box_sprite
		_:
			return

	main_editor.selected_box_colour = ""
	place_goal_position()




func place_goal_position() -> void:
	if main_editor.selected_box == "red":
		main_editor.tile_preview.texture = red_box_goal_texture
	elif main_editor.selected_box == "yellow":
		main_editor.tile_preview.texture = yellow_box_goal_texture
	elif main_editor.selected_box == "blue":
		main_editor.tile_preview.texture = blue_box_goal_texture
	else:
		return
	
	main_editor.selected_layer = null
	main_editor.selected_goal_colour = main_editor.selected_box
	main_editor.tile_preview.visible = true
	main_editor.mode_label.text = "Selected %s goal, click the canvas to place it" % main_editor.selected_goal_colour



func _place_box_goal_at(position: Vector2) -> void:
	#var goal_sprite: Sprite2D
	match main_editor.selected_goal_colour:
		"red":
			red_box_goal_sprite.texture = red_box_goal_texture
			red_box_goal_sprite.position = position
		"yellow":
			yellow_box_goal_sprite.texture = yellow_box_goal_texture
			yellow_box_goal_sprite.position = position
		"blue":
			blue_box_goal_sprite.texture = blue_box_goal_texture
			blue_box_goal_sprite.position = position
		_:
			return
	main_editor.selected_goal_colour = ""
	# after placing the goal, resume normal operations
	# reactivate all buttons
	main_editor.enable_buttons_and_interfaces()
	# make sure player can press other buttons
	main_editor.enable_all_buttons()
	
	main_editor.box_btn.button_pressed = true
	main_editor.show_box_editor()
