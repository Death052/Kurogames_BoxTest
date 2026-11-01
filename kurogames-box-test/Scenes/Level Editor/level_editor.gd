extends Node2D
class_name MainEditor

const COLLIDING_TILES := preload("res://Sprites/Tilesets/Colliding.tres")
const NOT_COLLIDING_TILES := preload("res://Sprites/Tilesets/NotColliding.tres")
# sub editors
@export var box_goal_editor : BoxGoalSubEditor
@export var others_editor : OthersSubEditor

# These nodes are defined in level_editor.tscn and are used by the editor
# to place tiles and update the status text.
@onready var colliding_layer: TileMapLayer = %CollidingTiles
@onready var not_colliding_layer: TileMapLayer = %NotCollidingTiles
@onready var tiles_scroll_container: ScrollContainer = %ScrollContainer
@onready var palette: VBoxContainer = %Palette
@onready var mode_label: Label = %ModeLabel
@onready var tile_preview: Sprite2D = %TilePreview
@onready var sprites_list: Node2D = %Objects

# save panel buttons and pop up
@onready var input_pop_up : PanelContainer = %InputPopup
@onready var pop_up_input : LineEdit = %Input
@onready var pop_up_submit : Button = %Submit
@onready var pop_up_cancel : Button = %Cancel


@export var default_preview_sprite : Texture2D

@onready var box_editor_center_container : CenterContainer = %BoxCenterContainer

# The selected tile determines both what gets placed and which tilemap
# receives it. Colliding and non-colliding tiles use separate layers.
var selected_layer: TileMapLayer
var selected_source_id := 0
var selected_atlas_coords := Vector2i.ZERO
var selected_box_colour := ""
var selected_goal_colour := ""
var selected_others := ""

# buttons to navigate different menus
@onready var tiles_btn : Button = %Tiles
@onready var box_btn : Button = %BoxButton
@onready var player_goal_btn : Button = %PlayerGoalButton
var currently_selected_btn : int
@onready var draw_button : Button = %Draw
@onready var erase_button : Button = %Erase2
var is_erasing := false


# buttons for instantiating boxes
@onready var red_box_btn : Button = %RedBoxBtn
@onready var yellow_box_btn : Button = %YellowBoxBtn
@onready var blue_box_btn : Button = %BlueBoxBtn
@onready var normal_box_btn : Button = %NormalBoxBtn




# current selected box (can be null)
var selected_box : String = ""

# buttons for dealing with player / goal
@onready var player_btn : Button = %PlayerBtn
@onready var goal_btn : Button = %GoalBtn
@onready var player_goal_editor_center_container : CenterContainer = %PlayerGoalCenterContainer

# for saving and playing
@onready var save_button : Button = %Save
@onready var play_button : Button = %Play
@export var save_node : SaveLevel

var saved_menu : int

func _ready() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_out(0.5)
	# play the music
	SoundManager.play_bgm("Editor_BGM")
	# make sure game knows its in the editor
	GameManager.in_editor_test = true
	currently_selected_btn = -1
	# connect the buttons to their functions
	tiles_btn.pressed.connect(show_tile_editor)
	box_btn.pressed.connect(show_box_editor)
	player_goal_btn.pressed.connect(show_player_goal_editor)
	draw_button.pressed.connect(_draw_mode)
	erase_button.pressed.connect(_erase_mode)
	# connect box buttons to their functions
	red_box_btn.pressed.connect(box_goal_editor._place_box_location.bind("red"))
	yellow_box_btn.pressed.connect(box_goal_editor._place_box_location.bind("yellow"))
	blue_box_btn.pressed.connect(box_goal_editor._place_box_location.bind("blue"))
	# connect Player and Goal buttons to their functions
	player_btn.pressed.connect(others_editor._place_other_location.bind("player"))
	goal_btn.pressed.connect(others_editor._place_other_location.bind("goal"))
	normal_box_btn.pressed.connect(others_editor._place_other_location.bind("normal_box"))
	# save and play buttons
	save_button.pressed.connect(_save_game)
	play_button.pressed.connect(_play_game)
	# save pop up buttons
	pop_up_submit.pressed.connect(_submit_new_save)
	pop_up_cancel.pressed.connect(_cancel_new_save)

	# Build the palette from every tile already defined in the two TileSet
	# resources. The editor does not need a manually maintained tile list.
	_add_tileset_to_palette("Colliding tiles", COLLIDING_TILES, colliding_layer)
	_add_tileset_to_palette("Non-colliding tiles", NOT_COLLIDING_TILES, not_colliding_layer)
	mode_label.text = "Select a tile, then click the canvas"
	# make sure the preview tile is false initially
	tile_preview.visible = false

	# initially, default editor to the player menu
	enable_buttons_and_interfaces()
	draw_button.button_pressed = true
	player_goal_btn.button_pressed = true
	show_player_goal_editor()
	saved_menu = currently_selected_btn

func _save_game() -> void:
	var level_string_path := GameManager.loaded_level_json
	# when trying to save game, check if the level_string_path exists in the game
	if level_string_path != "":
		save_node.save_level(sprites_list,colliding_layer,not_colliding_layer,level_string_path)
	else:
		show_save_game_input_popup()

func show_save_game_input_popup() -> void:
	input_pop_up.visible = true
	pop_up_input.clear()
	pop_up_input.grab_focus()

func _submit_new_save() -> void:
	var level_name := pop_up_input.text.strip_edges()
	if level_name.is_empty():
		pop_up_input.grab_focus()
		return

	if not level_name.to_lower().ends_with(".json"):
		level_name += ".json"
	GameManager.loaded_level_json = "res://Scenes/Custom Level/Saved_Levels/" + level_name
	input_pop_up.visible = false
	_save_game()

func _cancel_new_save() -> void:
	input_pop_up.visible = false

func _play_game() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_in(0.5)
	#await get_tree().create_timer(0.3).timeout
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
	if is_erasing:
		_erase_at()
		return
	if selected_layer == null and selected_box_colour.is_empty() and selected_goal_colour.is_empty() and selected_others.is_empty():
		return

	var canvas_position: Vector2 = $EditorCanvas.to_local(get_global_mouse_position())
	var snapped_position: Vector2 = _snap_to_grid(canvas_position)
	if not selected_box_colour.is_empty():
		box_goal_editor._place_box_at(snapped_position)
		return
	if not selected_goal_colour.is_empty():
		box_goal_editor._place_box_goal_at(snapped_position)
		return
	if not selected_others.is_empty():
		others_editor._place_other_at(snapped_position)
		return

	var tile_position: Vector2i = selected_layer.local_to_map(snapped_position)
	selected_layer.set_cell(tile_position, selected_source_id, selected_atlas_coords)


func disable_all_buttons():
	erase_button.disabled = true
	draw_button.disabled = true
	save_button.disabled = true
	play_button.disabled = true

func enable_all_buttons():
	erase_button.disabled = false
	draw_button.disabled = false
	save_button.disabled = false
	play_button.disabled = false


func _erase_mode() -> void:
	is_erasing = true
	erase_button.button_pressed = true
	draw_button.button_pressed = false
	selected_layer = null
	selected_box_colour = ""
	selected_goal_colour = ""
	selected_others = ""
	selected_box = ""
	tile_preview.texture = default_preview_sprite
	tile_preview.visible = true
	mode_label.text = "Erase mode: click a tile or object to remove it"
	# deactivate the menu on the left
	saved_menu = currently_selected_btn
	currently_selected_btn = -1
	disable_buttons_and_interfaces()

func _draw_mode() -> void:
	is_erasing = false
	draw_button.button_pressed = true
	erase_button.button_pressed = false
	tile_preview.texture = default_preview_sprite
	mode_label.text = "Draw mode: select a tile or object to place it"
	# show the menu and default it to the previously chosen draw menu
	enable_buttons_and_interfaces()
	# check what was the previous menu
	print("currently_selected_btn = ", currently_selected_btn)
	if saved_menu == 0:
		show_player_goal_editor()
	elif saved_menu == 1:
		show_box_editor()
	elif saved_menu == 2:
		show_tile_editor()
	currently_selected_btn = saved_menu
			
func _erase_at() -> void:
	var erase_position := tile_preview.global_position
	var children := sprites_list.get_children()
	for index in range(children.size() - 1, -1, -1):
		var child: Node = children[index]
		var sprite := child as Sprite2D
		if sprite == null or sprite.texture == null or not sprite.visible:
			continue
		if sprite.get_rect().has_point(sprite.to_local(erase_position)):
			sprite.texture = null
			return

	var canvas_position = $EditorCanvas.to_local(erase_position)
	var snapped_position := _snap_to_grid(canvas_position)
	var tile_position := colliding_layer.local_to_map(snapped_position)
	if colliding_layer.get_cell_source_id(tile_position) != -1:
		colliding_layer.erase_cell(tile_position)
		return
	if not_colliding_layer.get_cell_source_id(tile_position) != -1:
		not_colliding_layer.erase_cell(tile_position)

func show_tile_editor() -> void:
	# 2 represents the tiles button (what happens when tiles button pressed)
	if currently_selected_btn != 2:
		tiles_scroll_container.visible = true
		currently_selected_btn = 2
		tiles_btn.button_pressed = true
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
		box_btn.button_pressed = true
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
	# Snap to the center of the tile cell so objects share the tilemap's coordinate origin.
	return colliding_layer.map_to_local(colliding_layer.local_to_map(position))
