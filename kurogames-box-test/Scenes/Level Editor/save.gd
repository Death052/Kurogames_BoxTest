extends Node
class_name SaveLevel

const DEFAULT_LEVEL_PATH := "user://levels/level_1.json"

func save_level(sprites_list : Node2D, colliding_layer : TileMapLayer, not_colliding_layer : TileMapLayer, path: String = DEFAULT_LEVEL_PATH) -> void:
	var level_data := {
		"tiles": {
			"colliding": _save_tile_layer(colliding_layer),
			"not_colliding": _save_tile_layer(not_colliding_layer)
		},
		"objects": _save_objects(sprites_list)
	}

	var directory := DirAccess.open("user://")
	if directory == null:
		push_error("Could not access the user data directory.")
		return
	directory.make_dir_recursive("levels")

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not save level to %s." % path)
		return
	file.store_string(JSON.stringify(level_data, "\t"))
	file.close()

func _save_tile_layer(layer: TileMapLayer) -> Array[Dictionary]:
	var saved_tiles: Array[Dictionary] = []
	for cell in layer.get_used_cells():
		saved_tiles.append({
			"x": cell.x,
			"y": cell.y,
			"source_id": layer.get_cell_source_id(cell),
			"atlas_x": layer.get_cell_atlas_coords(cell).x,
			"atlas_y": layer.get_cell_atlas_coords(cell).y,
			"alternative": layer.get_cell_alternative_tile(cell)
		})
	return saved_tiles

func _save_objects(sprites_list : Node2D) -> Array[Dictionary]:
	var saved_objects: Array[Dictionary] = []
	for child in sprites_list.get_children():
		if not child is Sprite2D or not child.visible:
			continue
		# if there is nothing in the sprite, don't append it
		if child.texture == null:
			continue
		# append to object_date if type is 0
		var object_type := _get_object_type(child as Sprite2D)
		if object_type.is_empty():
			continue

		saved_objects.append({
			"type": object_type,
			"x": child.position.x,
			"y": child.position.y
		})
	print("saved_objects = ", saved_objects)
	return saved_objects

func _get_object_type(sprite: Sprite2D) -> String:
	match sprite.name:
		"Player":
			return "player"
		"Goal":
			return "goal"
		"RedBox":
			return "red_box"
		"YellowBox":
			return "yellow_box"
		"BlueBox":
			return "blue_box"
		"RedGoal":
			return "red_goal"
		"YellowGoal":
			return "yellow_goal"
		"BlueGoal":
			return "blue_goal"

	# has to be normal box if none of the above exist
	return "normal_box"
		
