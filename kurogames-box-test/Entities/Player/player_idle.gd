extends State

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	# wait until the its confirmed the player interacted with a push object
	state_machine.transition_to("player")
