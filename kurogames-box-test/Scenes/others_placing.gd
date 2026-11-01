extends Node
class_name OthersSubEditor

@export var main_editor : MainEditor

# Sprite References
@onready var player_sprite : Sprite2D = %Player
@onready var goal_sprite : Sprite2D = %Goal
# player and goal related textures
@export var player_texture : Texture2D 
@export var goal_texture : Texture2D 
@export var normal_box_texture : Texture2D


func _place_other_location(object_type: String) -> void:
	main_editor.disable_buttons_and_interfaces()
	# make sure player can't press other buttons
	main_editor.disable_all_buttons()
	
	main_editor.selected_layer = null
	main_editor.selected_box_colour = ""
	main_editor.selected_goal_colour = ""
	main_editor.selected_others = object_type

	if object_type == "player":
		main_editor.tile_preview.texture = player_texture
	elif object_type == "goal":
		main_editor.tile_preview.texture = goal_texture
	elif object_type == "normal_box":
		main_editor.tile_preview.texture = normal_box_texture
	else:
		main_editor.selected_others = ""
		main_editor.enable_buttons_and_interfaces()
		return

	main_editor.tile_preview.visible = true
	main_editor.mode_label.text = "Selected %s, click the canvas to place it" % object_type

func _place_other_at(position: Vector2) -> void:
	if main_editor.selected_others == "player":
		player_sprite.texture = player_texture
		player_sprite.position = position
		player_sprite.visible = true
	elif main_editor.selected_others == "goal":
		goal_sprite.texture = goal_texture
		goal_sprite.position = position
		goal_sprite.visible = true
	elif main_editor.selected_others == "normal_box":
		var new_box_sprite := Sprite2D.new()
		new_box_sprite.position = position
		new_box_sprite.texture = normal_box_texture
		main_editor.sprites_list.add_child(new_box_sprite)
		new_box_sprite.visible = true
	else:
		return

	main_editor.enable_buttons_and_interfaces()
	# make sure player can press other buttons
	main_editor.enable_all_buttons()
	
	if main_editor.selected_others == "player" || main_editor.selected_others == "goal":
		main_editor.show_player_goal_editor()
	if main_editor.selected_others == "normal_box":
		main_editor.show_box_editor()
		
	
	main_editor.selected_others = ""
	main_editor.tile_preview.visible = false
	main_editor.mode_label.text = "Player or goal placed"


	
