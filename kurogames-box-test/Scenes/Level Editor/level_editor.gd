extends Node2D

const GRID_SIZE := 16
const COLLIDING_TILES := preload("res://Sprites/Tilesets/Colliding.tres")
const NOT_COLLIDING_TILES := preload("res://Sprites/Tilesets/NotColliding.tres")


# These nodes are defined in level_editor.tscn and are used by the editor
# to place tiles and update the status text.
@onready var colliding_layer: TileMapLayer = $EditorCanvas/CollidingTiles
@onready var not_colliding_layer: TileMapLayer = $EditorCanvas/NotCollidingTiles
@onready var tiles_scroll_container: ScrollContainer = $Interface/PalettePanel/ScrollContainer
@onready var palette: VBoxContainer = $Interface/PalettePanel/ScrollContainer/Palette
@onready var mode_label: Label = $Interface/TopBar/ModeLabel
@onready var tile_preview: Sprite2D = $EditorCanvas/SpritePreviews/TilePreview
@onready var sprites_list: Node2D = $EditorCanvas/Objects
@export var default_preview_sprite : Texture2D

@onready var box_editor_center_container : CenterContainer = $Interface/PalettePanel/BoxCenterContainer

# The selected tile determines both what gets placed and which tilemap
# receives it. Colliding and non-colliding tiles use separate layers.
var selected_layer: TileMapLayer
var selected_source_id := 0
var selected_atlas_coords := Vector2i.ZERO
var selected_box_colour := ""
var selected_goal_colour := ""
var selected_others := ""

# buttons to navigate different menus
@onready var tiles_btn : Button = $Interface/ObjectTools/Tiles
@onready var box_btn : Button = $Interface/ObjectTools/BoxButton
@onready var player_goal_btn : Button = $Interface/ObjectTools/PlayerGoalButton
var currently_selected_btn : int


# buttons for instantiating boxes
@onready var red_box_btn : Button = $Interface/PalettePanel/BoxCenterContainer/HBoxBoxes/HBoxRed/RedBoxBtn
@onready var yellow_box_btn : Button = $Interface/PalettePanel/BoxCenterContainer/HBoxBoxes/HBoxYellow/YellowBoxBtn
@onready var blue_box_btn : Button = $Interface/PalettePanel/BoxCenterContainer/HBoxBoxes/HBoxBlue/BlueBoxBtn
@onready var normal_box_btn : Button = $Interface/PalettePanel/BoxCenterContainer/HBoxBoxes/HBoxNormal/NormalBoxBtn

# Sprite References
@onready var red_box_sprite : Sprite2D = $EditorCanvas/Objects/RedBox
@onready var red_box_goal_sprite : Sprite2D = $EditorCanvas/Objects/RedGoal
@onready var yellow_box_sprite : Sprite2D = $EditorCanvas/Objects/YellowBox
@onready var yellow_box_goal_sprite : Sprite2D = $EditorCanvas/Objects/YellowGoal
@onready var blue_box_sprite : Sprite2D = $EditorCanvas/Objects/BlueBox
@onready var blue_box_goal_sprite : Sprite2D = $EditorCanvas/Objects/BlueGoal

# box and goal related textures
@export var red_box_texture : Texture2D
@export var yellow_box_texture : Texture2D
@export var blue_box_texture : Texture2D
@export var red_box_goal_texture : Texture2D
@export var yellow_box_goal_texture : Texture2D
@export var blue_box_goal_texture : Texture2D
@export var normal_box_texture : Texture2D

# current selected box (can be null)
var selected_box : String = ""

# buttons for dealing with player / goal
@onready var player_btn : Button = $Interface/PalettePanel/PlayerGoalCenterContainer/HBoxBoxes/HBoxRed/PlayerBtn
@onready var goal_btn : Button = $Interface/PalettePanel/PlayerGoalCenterContainer/HBoxBoxes/HBoxYellow/GoalBtn
@onready var player_goal_editor_center_container : CenterContainer = $Interface/PalettePanel/PlayerGoalCenterContainer
# Sprite References
@onready var player_sprite : Sprite2D = $EditorCanvas/Objects/Player
@onready var goal_sprite : Sprite2D = $EditorCanvas/Objects/Goal
# player and goal related textures
@export var player_texture : Texture2D 
@export var goal_texture : Texture2D 

# for saving and playing
@onready var save_button : Button = $Interface/SaveLoadMarginContainer/PanelContainer/MarginContainer/HBoxContainer/Save
@onready var play_button : Button = $Interface/SaveLoadMarginContainer/PanelContainer/MarginContainer/HBoxContainer/Play
@export var save_node : SaveLevel

func _ready() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_out(0.5)
	
	currently_selected_btn = 0
	# connect the buttons to their functions
	tiles_btn.pressed.connect(show_tile_editor)
	box_btn.pressed.connect(show_box_editor)
	player_goal_btn.pressed.connect(show_player_goal_editor)
	# connect box buttons to their functions
	red_box_btn.pressed.connect(_place_box_location.bind("red"))
	yellow_box_btn.pressed.connect(_place_box_location.bind("yellow"))
	blue_box_btn.pressed.connect(_place_box_location.bind("blue"))
	# connect Player and Goal buttons to their functions
	player_btn.pressed.connect(_place_other_location.bind("player"))
	goal_btn.pressed.connect(_place_other_location.bind("goal"))
	normal_box_btn.pressed.connect(_place_other_location.bind("normal_box"))
	# save and play buttons
	save_button.pressed.connect(_save_game)
	play_button.pressed.connect(_play_game)
	
	
	# Build the palette from every tile already defined in the two TileSet
	# resources. The editor does not need a manually maintained tile list.
	_add_tileset_to_palette("Colliding tiles", COLLIDING_TILES, colliding_layer)
	_add_tileset_to_palette("Non-colliding tiles", NOT_COLLIDING_TILES, not_colliding_layer)
	mode_label.text = "Select a tile, then click the canvas"
	# make sure the preview tile is false initially
	tile_preview.visible = false


func _save_game() -> void:
	var level_string_path = "res://Scenes/Custom Level/Saved_Levels/level1.json"
	save_node.save_level(sprites_list,colliding_layer,not_colliding_layer,level_string_path)
	pass

func _play_game() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_in(0.5)
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://Scenes/Custom Level/custom_level.tscn")


func _process(delta: float) -> void:
	#if selected_layer == null:
		#tile_preview.visible = false
		#return
	tile_preview.visible = true
	# Get mouse position relative to the editor canvas
	var canvas_position: Vector2 = $EditorCanvas.to_local(get_global_mouse_position())
	# Snap it to your grid using _snap_to_grid function
	var snapped_position: Vector2 = _snap_to_grid(canvas_position)
	# Position the preview sprite. 
	tile_preview.global_position = $EditorCanvas.to_global(snapped_position)

func _unhandled_input(event: InputEvent) -> void:
	# A left click places the currently selected tile. UI clicks are handled
	# by the UI controls and do not reach this method.
	if not event is InputEventMouseButton:
		return
	if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if selected_layer == null and selected_box_colour.is_empty() and selected_goal_colour.is_empty() and selected_others.is_empty():
		return

	var canvas_position: Vector2 = $EditorCanvas.to_local(get_global_mouse_position())
	var snapped_position: Vector2 = _snap_to_grid(canvas_position)
	if not selected_box_colour.is_empty():
		_place_box_at(snapped_position)
		return
	if not selected_goal_colour.is_empty():
		_place_box_goal_at(snapped_position)
		return
	if not selected_others.is_empty():
		_place_other_at(snapped_position)
		return

	var tile_position: Vector2i = selected_layer.local_to_map(snapped_position)
	selected_layer.set_cell(tile_position, selected_source_id, selected_atlas_coords)

func show_tile_editor() -> void:
	# 2 represents the tiles button (what happens when tiles button pressed)
	if currently_selected_btn != 2:
		tiles_scroll_container.visible = true
		currently_selected_btn = 2
		box_btn.button_pressed = true
		deselect_other_components(currently_selected_btn)

func show_player_goal_editor() -> void:
	if currently_selected_btn != 0:
		player_goal_editor_center_container.visible = true
		currently_selected_btn = 0
		player_goal_btn.button_pressed = true
		deselect_other_components(currently_selected_btn)

func show_box_editor() -> void:
	if currently_selected_btn != 1:
		box_editor_center_container.visible = true
		currently_selected_btn = 1
		tiles_btn.button_pressed = true
		deselect_other_components(currently_selected_btn)

func deselect_other_components(current_button : int) -> void:
	if current_button != 0:
		player_goal_editor_center_container.visible = false
		player_goal_btn.button_pressed = false
	
	if current_button != 1:
		box_editor_center_container.visible = false
		box_btn.button_pressed = false
	
	if current_button != 2:
		tiles_scroll_container.visible = false
		tiles_btn.button_pressed = false
		

func disable_buttons_and_interfaces():
	deselect_other_components(-1)
	tiles_btn.disabled = true
	player_goal_btn.disabled = true
	box_btn.disabled = true
	currently_selected_btn = -1

func enable_buttons_and_interfaces():
	tiles_btn.disabled = false
	player_goal_btn.disabled = false
	box_btn.disabled = false
	tile_preview.texture = default_preview_sprite

func _place_other_location(object_type: String) -> void:
	disable_buttons_and_interfaces()
	selected_layer = null
	selected_box_colour = ""
	selected_goal_colour = ""
	selected_others = object_type

	if object_type == "player":
		tile_preview.texture = player_texture
	elif object_type == "goal":
		tile_preview.texture = goal_texture
	elif object_type == "normal_box":
		tile_preview.texture = normal_box_texture
	else:
		selected_others = ""
		enable_buttons_and_interfaces()
		return

	tile_preview.visible = true
	mode_label.text = "Selected %s, click the canvas to place it" % object_type

func _place_other_at(position: Vector2) -> void:
	if selected_others == "player":
		player_sprite.texture = player_texture
		player_sprite.position = position
		player_sprite.visible = true
	elif selected_others == "goal":
		goal_sprite.texture = goal_texture
		goal_sprite.position = position
		goal_sprite.visible = true
	elif selected_others == "normal_box":
		var new_box_sprite := Sprite2D.new()
		new_box_sprite.position = position
		new_box_sprite.offset = Vector2(8,8)
		new_box_sprite.texture = normal_box_texture
		sprites_list.add_child(new_box_sprite)
		new_box_sprite.visible = true
	else:
		return

	enable_buttons_and_interfaces()
	if selected_others == "player" || selected_others == "goal":
		show_player_goal_editor()
	if selected_others == "normal_box":
		show_box_editor()
		
	
	selected_others = ""
	tile_preview.visible = false
	mode_label.text = "Player or goal placed"

func _place_box_location(colour : String) -> void:
	# disable all buttons and interfaces 
	disable_buttons_and_interfaces()
	selected_others = ""
	# set tilepreview to the box sprite
	if colour == "red":
		selected_box = "red"
		tile_preview.texture = red_box_texture
		red_box_sprite.texture = null
		red_box_goal_sprite.texture = null
		
	elif colour == "yellow":
		selected_box = "yellow"
		tile_preview.texture = yellow_box_texture
		yellow_box_sprite.texture = null
		yellow_box_goal_sprite.texture = null
		
	elif colour == "blue":
		selected_box = "blue"
		tile_preview.texture = blue_box_texture
		blue_box_sprite.texture = null
		blue_box_goal_sprite.texture = null
		
	else:
		return

	selected_layer = null
	selected_box_colour = colour
	tile_preview.visible = true
	mode_label.text = "Selected %s box, click the canvas to place it" % colour


func _place_box_at(position: Vector2) -> void:
	var box_sprite: Sprite2D
	match selected_box_colour:
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

	selected_box_colour = ""
	place_goal_position()


func _place_box_goal_at(position: Vector2) -> void:
	#var goal_sprite: Sprite2D
	match selected_goal_colour:
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
	selected_goal_colour = ""
	# after placing the goal, resume normal operations
	# reactivate all buttons
	enable_buttons_and_interfaces()
	
	box_btn.button_pressed = true
	show_box_editor()
	


func place_goal_position() -> void:
	if selected_box == "red":
		tile_preview.texture = red_box_goal_texture
	elif selected_box == "yellow":
		tile_preview.texture = yellow_box_goal_texture
	elif selected_box == "blue":
		tile_preview.texture = blue_box_goal_texture
	else:
		return
	
	selected_layer = null
	selected_goal_colour = selected_box
	tile_preview.visible = true
	mode_label.text = "Selected %s goal, click the canvas to place it" % selected_goal_colour



func _add_tileset_to_palette(title: String, tile_set: TileSet, layer: TileMapLayer) -> void:
	# Create one palette section and grid for a TileSet.
	var section_label := Label.new()
	section_label.text = title
	section_label.add_theme_font_size_override("font_size", 18)
	palette.add_child(section_label)

	var tile_grid := GridContainer.new()
	tile_grid.columns = 4
	palette.add_child(tile_grid)

	for source_index in tile_set.get_source_count():
		var source_id: int = tile_set.get_source_id(source_index)
		var atlas_source := tile_set.get_source(source_id) as TileSetAtlasSource
		if atlas_source == null:
			continue

		for tile_index in atlas_source.get_tiles_count():
			var atlas_coords: Vector2i = atlas_source.get_tile_id(tile_index)
			var tile_button := Button.new()
			tile_button.custom_minimum_size = Vector2(56, 56)
			tile_button.tooltip_text = "%s %s" % [title, atlas_coords]
			# Store the tile information in the button's signal callback so
			# selecting a button changes the active tile.
			tile_button.pressed.connect(
				_select_tile.bind(layer, source_id, atlas_coords)
			)

			# AtlasTexture displays only this tile's region instead of the
			# entire source texture.
			var preview := TextureRect.new()
			var atlas_texture := AtlasTexture.new()
			atlas_texture.atlas = atlas_source.get_texture()
			atlas_texture.region = atlas_source.get_tile_texture_region(atlas_coords)
			preview.texture = atlas_texture
			preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile_button.add_child(preview)
			tile_grid.add_child(tile_button)

func _select_tile(layer: TileMapLayer, source_id: int, atlas_coords: Vector2i) -> void:
	# Remember the tile selected from the palette until the canvas is clicked.
	selected_layer = layer
	selected_box_colour = ""
	selected_goal_colour = ""
	selected_others = ""
	selected_source_id = source_id
	selected_atlas_coords = atlas_coords
	mode_label.text = "Selected tile %s" % atlas_coords

func _snap_to_grid(position: Vector2) -> Vector2:
	# Keep tiles aligned with the same 16-pixel grid used by the tilemaps.
	return Vector2(
		round(position.x / GRID_SIZE) * GRID_SIZE,
		round(position.y / GRID_SIZE) * GRID_SIZE
	)
