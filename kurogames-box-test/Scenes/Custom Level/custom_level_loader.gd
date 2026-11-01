extends Node2D

const LEVEL_PATH := "user://levels/level_1.json"
const COLLIDING_TILES := preload("res://Sprites/Tilesets/Colliding.tres")
const NOT_COLLIDING_TILES := preload("res://Sprites/Tilesets/NotColliding.tres")

const TEXTURES := {
	"player": preload("res://Entities/Player/Player.tscn"),
	"goal": preload("res://Entities/Goal/goal.tscn"),
	"red_box": preload("res://Entities/Box Pair/Resources/red_box_pair.tres"),
	"yellow_box": preload("res://Entities/Box Pair/Resources/yellow_box_pair.tres"),
	"blue_box": preload("res://Entities/Box Pair/Resources/blue_box_pair.tres"),
	"normal_box": preload("res://Entities/Box Pair/Box/Normal_Box.tscn"),
	"red_goal": preload("res://Entities/Box Pair/Resources/red_box_pair.tres"),
	"yellow_goal": preload("res://Entities/Box Pair/Resources/yellow_box_pair.tres"),
	"blue_goal": preload("res://Entities/Box Pair/Resources/blue_box_pair.tres")
}

const coloured_box_pair = preload("res://Entities/Box Pair/box_pair.tscn")

# get box pair resources
@onready var red_pair : BoxPair = preload("res://Entities/Box Pair/Resources/red_box_pair.tres")
@onready var yellow_pair : BoxPair = preload("res://Entities/Box Pair/Resources/yellow_box_pair.tres")
@onready var blue_pair : BoxPair = preload("res://Entities/Box Pair/Resources/blue_box_pair.tres")


@onready var colliding_layer: TileMapLayer = $CollidingTiles
@onready var not_colliding_layer: TileMapLayer = $NotCollidingTiles
@onready var objects: Node2D = $Objects

func _ready() -> void:
	y_sort_enabled = true
	load_level(GameManager.loaded_level_json)
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_out(0.5)
	# play the music
	SoundManager.play_bgm("InGame_BGM")
	

func load_level(path: String = LEVEL_PATH) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not load level from %s." % path)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("Level data is not a valid JSON object.")
		return

	var level_version := int(parsed.get("version", 1))
	var is_saved_level := path.get_base_dir().get_file() == "Saved_Levels"

	_load_tile_layer(parsed.get("tiles", {}).get("colliding", []), colliding_layer)
	_load_tile_layer(parsed.get("tiles", {}).get("not_colliding", []), not_colliding_layer)
	var saved_objects: Array = parsed.get("objects", [])
	var saved_box_goals: Array = parsed.get("box_goals", saved_objects)
	_load_objects(saved_objects, saved_box_goals, level_version, is_saved_level)

func _load_tile_layer(saved_tiles: Array, layer: TileMapLayer) -> void:
	for tile in saved_tiles:
		var cell := Vector2i(int(tile["x"]), int(tile["y"]))
		var atlas_coords := Vector2i(int(tile["atlas_x"]), int(tile["atlas_y"]))
		layer.set_cell(
			cell,
			int(tile["source_id"]),
			atlas_coords,
			int(tile.get("alternative", 0))
		)

func load_box_resources(folder_path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir := DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				# In exported builds, original extensions (like .tres) often get a '.remap' or '.import' suffix
				if file_name.ends_with(".tres") or file_name.ends_with(".res"):
					var full_path := folder_path.path_join(file_name)
					var resource := load(full_path)
					if resource:
						resources.append(resource)
						
			file_name = dir.get_next()
	else:
		printerr("Could not open folder: ", folder_path)
		
	return resources


func _load_objects(
	saved_objects: Array,
	goal_objects: Array,
	level_version: int,
	is_saved_level: bool
) -> void:
	for object_data in saved_objects:
		var object_type: String = object_data["type"]
		var object_position := Vector2(float(object_data["x"]), float(object_data["y"]))
		if level_version < 2:
			object_position += colliding_layer.map_to_local(Vector2i.ZERO)
		#var texture: Texture2D = TEXTURES.get(object_type)
		var object_instance = TEXTURES.get(object_type)
		#if texture == null:
			#push_warning("Unknown level object type: %s" % object_type)
			#continue
		# if the object is a player
		if object_type == "player":
			var player_instance : Player = object_instance.instantiate()
			player_instance.global_position = object_position
			player_instance.add_to_group("Player") 
			add_child(player_instance)
		# if the object is a goal
		if object_type == "goal":
			var goal_instance : Goal = object_instance.instantiate()
			goal_instance.global_position = object_position
			goal_instance.goal_level_num = -1 if is_saved_level else GameManager.current_attempting_level
			add_child(goal_instance)
		# if the object is a normal box
		if object_type == "normal_box":
			var normal_box_instance : NormalBox = object_instance.instantiate()
			var box_position := object_position
			normal_box_instance.position = box_position
			normal_box_instance.box_position = box_position
			normal_box_instance.z_index = 0
			normal_box_instance.collision_mask = 10
			add_child(normal_box_instance)
			
		# if the object is a coloured box
		if object_type == "red_box" or object_type == "yellow_box" or object_type == "blue_box":
			# instantiate box and set box position
			var box_goal_instance : GoalBoxPair = coloured_box_pair.instantiate()
			var box_position := object_position
			box_goal_instance.position = box_position
			box_goal_instance.box_position = Vector2.ZERO
			# allow y sort
			box_goal_instance.y_sort_enabled = true
			# set box settings based on colour
			if object_type == "red_box":
				box_goal_instance.box_pair_resource = red_pair
			elif object_type == "blue_box":
				box_goal_instance.box_pair_resource = blue_pair
			elif object_type == "yellow_box":
				box_goal_instance.box_pair_resource = yellow_pair
			# set the goal position based on the matching colour
			var goal_type := object_type.replace("_box", "_goal")
			for goal_data in goal_objects:
				if goal_data.get("type") == goal_type:
					var goal_position := Vector2(float(goal_data["x"]), float(goal_data["y"]))
					if level_version < 2:
						goal_position += colliding_layer.map_to_local(Vector2i.ZERO)
					box_goal_instance.goal_position = goal_position - box_position
					break
			add_child(box_goal_instance)
				
		
		
		#if object_type == "red_box" or object_type == "yellow_box" or object_type == "blue_box":
			## instantiate box and set box position
			#var box_goal_instance : GoalBoxPair = coloured_box_pair.instantiate()
			#box_goal_instance.box_position = Vector2(float(object_data["x"]), float(object_data["y"]))
			## if box is red, find the red goal as well
			#if object_type == "red_box":
				## place the tres
				#box_goal_instance.box_pair_resource = object_instance
				#for goal_data in goal_objects:
					#var goal_type: String = goal_data["type"]
					#if goal_type == "red_goal":
						#box_goal_instance.goal_position = Vector2(float(goal_data["x"]), float(goal_data["y"]))
			#
			#add_child(box_goal_instance)
					
			
			#if object_type == "red_box":
				
				# get goal position
				
				
		
		
		
		
		#var sprite := Sprite2D.new()
		#sprite.texture = texture
		#sprite.position = Vector2(float(object_data["x"]), float(object_data["y"]))
		#sprite.offset = Vector2(8, 8)
		#objects.add_child(sprite)
