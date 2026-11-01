extends Node

@onready var main_editor: MainEditor = get_parent() as MainEditor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# if the load level to json string isn't empty, it means a level is being edited
	if GameManager.loaded_level_json != "":
		call_deferred("load_json_into_editor")


func load_json_into_editor() -> void:
	var path := GameManager.loaded_level_json
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not load level data from %s." % path)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("Level data in %s is not a valid JSON object." % path)
		return

	var tile_data = parsed.get("tiles", {})
	if tile_data is Dictionary:
		var colliding_layer := get_node_or_null("../EditorCanvas/CollidingTiles") as TileMapLayer
		var not_colliding_layer := get_node_or_null("../EditorCanvas/NotCollidingTiles") as TileMapLayer
		_load_tile_layer(tile_data.get("colliding", []), colliding_layer)
		_load_tile_layer(tile_data.get("not_colliding", []), not_colliding_layer)

	var saved_objects = parsed.get("objects", [])
	if saved_objects is Array:
		_load_objects(saved_objects, int(parsed.get("version", 1)))

func _load_tile_layer(saved_tiles, layer: TileMapLayer) -> void:
	if not saved_tiles is Array or layer == null:
		if layer == null:
			push_error("Cannot restore tiles because the target TileMapLayer is missing.")
		return

	for tile in saved_tiles:
		if not tile is Dictionary:
			continue
		if not tile.has_all(["x", "y", "source_id", "atlas_x", "atlas_y"]):
			push_warning("Skipping tile with missing data.")
			continue

		var cell := Vector2i(int(tile["x"]), int(tile["y"]))
		var atlas_coords := Vector2i(int(tile["atlas_x"]), int(tile["atlas_y"]))
		layer.set_cell(
			cell,
			int(tile["source_id"]),
			atlas_coords,
			int(tile.get("alternative", 0))
		)

func _load_objects(saved_objects: Array, level_version: int) -> void:
	for child in main_editor.sprites_list.get_children():
		var sprite := child as Sprite2D
		if sprite == null:
			continue
		if sprite.name.begins_with("NormalBox"):
			sprite.queue_free()
		else:
			sprite.texture = null

	for object_data in saved_objects:
		if not object_data is Dictionary:
			continue
		var object_type: String = str(object_data.get("type", ""))
		if not object_data.has_all(["x", "y"]):
			push_warning("Skipping object with missing position data.")
			continue

		var position := Vector2(float(object_data["x"]), float(object_data["y"]))
		if level_version < 2:
			position += main_editor.colliding_layer.map_to_local(Vector2i.ZERO)
		var sprite := _get_fixed_sprite(object_type)
		if sprite != null:
			sprite.texture = _get_object_texture(object_type)
			sprite.position = position
			sprite.visible = sprite.texture != null
		elif object_type == "normal_box":
			_create_normal_box(position)
		else:
			push_warning("Skipping unknown editor object type: %s." % object_type)

func _get_fixed_sprite(object_type: String) -> Sprite2D:
	match object_type:
		"player":
			return main_editor.others_editor.player_sprite
		"goal":
			return main_editor.others_editor.goal_sprite
		"red_box":
			return main_editor.box_goal_editor.red_box_sprite
		"yellow_box":
			return main_editor.box_goal_editor.yellow_box_sprite
		"blue_box":
			return main_editor.box_goal_editor.blue_box_sprite
		"red_goal":
			return main_editor.box_goal_editor.red_box_goal_sprite
		"yellow_goal":
			return main_editor.box_goal_editor.yellow_box_goal_sprite
		"blue_goal":
			return main_editor.box_goal_editor.blue_box_goal_sprite
		_:
			return null

func _get_object_texture(object_type: String) -> Texture2D:
	match object_type:
		"player":
			return main_editor.others_editor.player_texture
		"goal":
			return main_editor.others_editor.goal_texture
		"red_box":
			return main_editor.box_goal_editor.red_box_texture
		"yellow_box":
			return main_editor.box_goal_editor.yellow_box_texture
		"blue_box":
			return main_editor.box_goal_editor.blue_box_texture
		"red_goal":
			return main_editor.box_goal_editor.red_box_goal_texture
		"yellow_goal":
			return main_editor.box_goal_editor.yellow_box_goal_texture
		"blue_goal":
			return main_editor.box_goal_editor.blue_box_goal_texture
		_:
			return null

func _create_normal_box(position: Vector2) -> void:
	var normal_box := Sprite2D.new()
	normal_box.name = "NormalBox"
	normal_box.position = position
	normal_box.texture = main_editor.others_editor.normal_box_texture
	normal_box.visible = true
	main_editor.sprites_list.add_child(normal_box)
