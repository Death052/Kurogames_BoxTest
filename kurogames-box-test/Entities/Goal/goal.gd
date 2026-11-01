extends Node
class_name Goal

var goal_box_pairs_in_scene : Array[GoalBoxPair]
# Goal State
var is_activated : bool
# Goal Animation and sprite
var animation_player : AnimationPlayer
var sprite : Sprite2D
# the player
var player : Player
# if the goal is from an existing level, give it a number
@export var goal_level_num : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get the animation player and sprite
	animation_player = get_node("AnimationPlayer")
	sprite = get_node("Sprite2D")
	# the goal always start off deactivated
	set_deactivate()
	# at start of scene, get the goal box pairs in scene
	goal_box_pairs_in_scene = get_goal_box_pairs()
	connect_goal_box_pair_signals()
	GameUi.update_box_count_ui(goal_box_pairs_in_scene)
	# get the player in scene
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		push_error("%s could not find a Player." % name)


# get all goal box pairs in the scene 
# (Should get called each time a new box pair is added in scene)
func get_goal_box_pairs() -> Array[GoalBoxPair]:
	var goal_box_pairs: Array[GoalBoxPair] = []
	var current_scene := get_tree().current_scene

	if current_scene == null:
		return goal_box_pairs

	for node in current_scene.find_children("*", "GoalBoxPair", true, false):
		goal_box_pairs.append(node as GoalBoxPair)
	
	return goal_box_pairs

# make sure the goal detects all box goal pairs
func connect_goal_box_pair_signals() -> void:
	for pair in goal_box_pairs_in_scene:
		if not pair.box_reached.is_connected(validate_box_pairs):
			pair.box_reached.connect(validate_box_pairs)
		if not pair.box_left.is_connected(validate_box_pairs):
			pair.box_left.connect(validate_box_pairs)
		
		
# when called, check how many box goal pairs in scene have reached goal
func validate_box_pairs() -> void:
	var validate_count : int = 0
	for pair in goal_box_pairs_in_scene:
		if pair.box_pair_is_reached == true:
			validate_count += 1
	GameUi.update_box_count_ui(goal_box_pairs_in_scene)
	# if the count is the same, activate goal
	if validate_count == goal_box_pairs_in_scene.size():
		set_activate()
		
	else:
		set_deactivate()

func set_activate() -> void:
	is_activated = true
	animation_player.play("Goal Activated")
	ShaderManager.set_outline(sprite, Color(0.353, 0.738, 0.382, 1.0))

func set_deactivate() -> void:
	is_activated = false
	animation_player.play("Goal Deactivated")
	ShaderManager.remove_shader(sprite)


func _on_area_2d_body_entered(body: Node2D) -> void:
	# if the player enters the goal, pass the level
	if body == player:
		if is_activated == true:
			# if goal is -1, it means its a custom level
			if goal_level_num != -1:
				# mark the level as complete
				GameManager.level_completion[goal_level_num] = true
			else:
				# -1 means its a custom level. Choose to either go to the editor or
				# go back to level select
				TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
				await TransitionUi.slide_in(0.5)
				await get_tree().create_timer(0.3).timeout
				# Choose to either go to the editor
				if GameManager.in_editor_test == true:
					get_tree().change_scene_to_file("res://Scenes/Level Editor/level_editor.tscn")
					return
					
					
			# Go back to the level screen
			TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
			await TransitionUi.slide_in(0.5)
			await get_tree().create_timer(0.3).timeout
			get_tree().change_scene_to_file("res://Scenes/Level Selection/level_selection_screen.tscn")
			return
			
