extends Node

var goal_box_pairs_in_scene : Array[GoalBoxPair]
# Goal State
var is_activated : bool
# Goal Animation and sprite
var animation_player : AnimationPlayer
var sprite : Sprite2D

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
