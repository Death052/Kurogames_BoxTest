extends Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TransitionUi.set_transition_color(Color(0.0, 0.786, 0.786, 1.0))
	await TransitionUi.slide_out(0.5)
	# always set the json level string to empty at the start of level_selection
	GameManager.loaded_level_json = ""
	# play the music
	SoundManager.play_bgm("LevelSelection_BGM")
	
	#_load_saved_levels()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
