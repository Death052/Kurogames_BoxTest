extends Node2D

const LEVEL_PATH := "user://levels/level_1.json"
const COLLIDING_TILES := preload("res://Sprites/Tilesets/Colliding.tres")
const NOT_COLLIDING_TILES := preload("res://Sprites/Tilesets/NotColliding.tres")

const TEXTURES := {
	"player": preload("res://Sprites/Entities/player_icon.png"),
	"goal": preload("res://Sprites/Entities/goal_icon.png"),
	"red_box": preload("res://Sprites/Entities/box_red_1.png"),
	"red_goal": preload("res://Sprites/Entities/box_goal_red_1.png"),
	"yellow_box": preload("res://Sprites/Entities/box_yellow_1.png"),
	"yellow_goal": preload("res://Sprites/Entities/box_goal_yellow_1.png"),
	"blue_box": preload("res://Sprites/Entities/box_blue_1.png"),
	"blue_goal": preload("res://Sprites/Entities/box_goal_blue_1.png"),
	"normal_box": preload("res://Sprites/Entities/box.png")
}

@onready var colliding_layer: TileMapLayer = $CollidingTiles
@onready var not_colliding_layer: TileMapLayer = $NotCollidingTiles
@onready var objects: Node2D = $Objects

func _ready() -> void:
	load_level("res://Scenes/Custom Level/Saved_Levels/level1.json")
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_out(0.5)

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

	_load_tile_layer(parsed.get("tiles", {}).get("colliding", []), colliding_layer)
	_load_tile_layer(parsed.get("tiles", {}).get("not_colliding", []), not_colliding_layer)
	_load_objects(parsed.get("objects", []))

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

func _load_objects(saved_objects: Array) -> void:
	for object_data in saved_objects:
		var object_type: String = object_data["type"]
		var texture: Texture2D = TEXTURES.get(object_type)
		if texture == null:
			push_warning("Unknown level object type: %s" % object_type)
			continue

		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.position = Vector2(float(object_data["x"]), float(object_data["y"]))
		sprite.offset = Vector2(8, 8)
		objects.add_child(sprite)
