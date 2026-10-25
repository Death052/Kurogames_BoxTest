extends Node

@export var initial_state_path: NodePath
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.actor = get_parent()
			child.state_machine = self

	if initial_state_path:
		current_state = get_node(initial_state_path) as State

	if current_state:
		if not get_parent().is_node_ready():
			await get_parent().ready
		current_state.enter()

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func transition_to(new_state_name: String) -> void:
	var target_state = states.get(new_state_name.to_lower())
	if not target_state or not current_state:
		return

	current_state.exit()
	current_state = target_state
	current_state.enter()
