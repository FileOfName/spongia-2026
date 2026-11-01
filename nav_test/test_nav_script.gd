extends CharacterBody2D


const SPEED = 300.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	return
	var mouse = get_global_mouse_position()

	nav_agent.target_position = mouse

	if nav_agent.is_navigation_finished():
		return


	var target_pos = nav_agent.get_next_path_position()
	var new_velocity = global_position.direction_to(target_pos) * SPEED

	if nav_agent.avoidance_enabled:
		nav_agent.velocity = new_velocity
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

	move_and_slide()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
