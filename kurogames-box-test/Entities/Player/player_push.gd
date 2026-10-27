extends State

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	state_machine.transition_to("walk")
