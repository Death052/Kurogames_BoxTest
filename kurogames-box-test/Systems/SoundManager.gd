extends Node2D

@export var mute: bool = false
@export var fade_duration: float = 1.0

var current_bgm: AudioStreamPlayer = null
var bgm_players: Dictionary = {}
var sfx_players: Dictionary = {}

@onready var bgm_container = %BGM
@onready var sfx_container = %SoundFX

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cache_players()
	
	# Connect to all existing and future buttons to play click sound
	get_tree().node_added.connect(_on_node_added)
	_connect_buttons_recursive(get_tree().root)

func _on_node_added(node: Node):
	if node is BaseButton:
		_connect_button(node)

func _connect_buttons_recursive(node: Node):
	if node is BaseButton:
		_connect_button(node)
	for child in node.get_children():
		_connect_buttons_recursive(child)

func _connect_button(button: BaseButton):
	if not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	play_sfx("SeButtonClick")

func _cache_players():
	# Cache BGM players
	if bgm_container:
		for child in bgm_container.get_children():
			if child is AudioStreamPlayer:
				bgm_players[child.name] = child
				child.volume_db = -80.0 # Start silent
	
	# Cache SFX players recursively
	if sfx_container:
		_cache_sfx_recursive(sfx_container)

func _cache_sfx_recursive(node: Node):
	for child in node.get_children():
		if child is AudioStreamPlayer:
			sfx_players[child.name] = child
		_cache_sfx_recursive(child)

## Plays BGM with a fade transition
func play_bgm(music_name: String):
	print("AudioManager: Attempting to play BGM: ", music_name)
	if not bgm_players.has(music_name):
		push_warning("AudioManager: BGM '%s' not found." % music_name)
		return
	
	var new_bgm = bgm_players[music_name]
	if current_bgm == new_bgm:
		if not new_bgm.playing:
			new_bgm.play()
		return
	
	var tween = create_tween().set_parallel(true)
	
	# Fade out current music
	if current_bgm and current_bgm.playing:
		var last_bgm = current_bgm
		tween.tween_property(last_bgm, "volume_db", -80.0, fade_duration)
		# Stop after fade
		get_tree().create_timer(fade_duration).timeout.connect(func(): 
			if last_bgm != current_bgm: 
				last_bgm.stop()
		)
	
	# Fade in new music
	current_bgm = new_bgm
	if not mute:
		current_bgm.volume_db = -50
		current_bgm.play()
		tween.tween_property(current_bgm, "volume_db", 0.0, fade_duration)
		print("AudioManager: Successfully started fading in: ", music_name)

## Plays a sound effect by node name
func play_sfx(sfx_name: String):
	if mute: return
	
	if sfx_players.has(sfx_name):
		sfx_players[sfx_name].play()
	else:
		push_warning("AudioManager: SFX '%s' not found." % sfx_name)

## Stops a sound effect by node name
func stop_sfx(sfx_name: String, fade_out: bool = false):
	if sfx_players.has(sfx_name):
		var player = sfx_players[sfx_name]
		if fade_out:
			var tween = create_tween()
			tween.tween_property(player, "volume_db", -80.0, 0.5)
			tween.finished.connect(func(): player.stop())
		else:
			player.stop()
	else:
		push_warning("AudioManager: SFX '%s' not found." % sfx_name)


## Mutes or unmutes the audio manager
func set_mute(is_muted: bool):
	mute = is_muted
	if mute:
		if current_bgm: current_bgm.stop()
	else:
		if current_bgm: 
			current_bgm.volume_db = 0.0
			current_bgm.play()
