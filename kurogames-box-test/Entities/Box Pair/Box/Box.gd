class_name Box
extends Pushable
var can_pickup: bool = false

func _ready() -> void:
	super._ready()
	if player == null:
		push_error("%s could not find a node in the Player group." % name)
		return
	player.interactionPressed.connect(_pick_up_pushable)
	
# once player picks up the box, transition to push state
func _pick_up_pushable() -> void:
	if can_pickup:
		player.begin_pushing(self)

func _on_check_player_body_entered(body: Node2D) -> void:
	if body == player:
		ShaderManager.set_outline(sprite, Color(0.375, 0.53, 0.903, 1.0))
		can_pickup = true

func _on_check_player_body_exited(body: Node2D) -> void:
	if body == player:
		ShaderManager.remove_shader(sprite)
		can_pickup = false
