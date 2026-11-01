class_name Enemy

extends Entity

@export var SPEED: float = 200
@export var WANDER_SPEED: float = 60
@export var WANDER_DISTANCE = 400
@export var WANDER_DELAY = 4
@export var DAMAGE = 20
@export var ATTACK_COOLDOWN: float = 1
@export var WHOOSH_ARC = 120
@export var WHOOSH_COLOR = Color(1, 1, 1)

var is_chasing = false
var target: Player = null
var _wander_delay = 0
var _attack_cooldown = 0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hit_area: Area2D = $HitArea

func _ready() -> void:
	$NavigationAgent2D.radius = $CollisionShape2D.shape.radius

func _on_enter_area_entered(body: Node2D) -> void:
	if body is Player:
		target = body

func _on_exit_area_exited(body: Node2D) -> void:
	if body is Player:
		target = null

func _on_hit_area_entered(body: Node2D) -> void:
	# ano, asi by som mal pouzit to co pouziva player, ale s tym sa mi nechce hrat, bite me
	if body is Player:
		_hit(body)

func _process(delta: float) -> void:
	super._process(delta)
	_wander_delay = max(_wander_delay - delta, 0)
	_attack_cooldown -= delta
	if _attack_cooldown < 0:
		_attack_cooldown = 0
		for b in hit_area.get_overlapping_bodies():
			if b is Player:
				_hit(b)

func _hit(player: Player):
	if health == 0 || _attack_cooldown != 0:
		return
	player.damage(DAMAGE)
	_attack_cooldown = ATTACK_COOLDOWN


	var whoosh := Whoosh.make(Whoosh.Kind.ARC, get_angle_to(player.global_position), $HitArea/CollisionShape2D.shape.radius, WHOOSH_COLOR)
	whoosh.sweep = deg_to_rad(WHOOSH_ARC)
	_show_whoosh(whoosh)

func damage(amount: int):
	super.damage(amount)

func _death_anim_finished():
	super._death_anim_finished()
	Pickup.drop(get_parent(), global_position, Item.new("coin"))

func _physics_process(delta: float) -> void:
	if health == 0:
		return

	if target != null:
		nav_agent.target_position = target.global_position

	if nav_agent.is_navigation_finished():
		if target == null && _wander_delay == 0:
			var space_state := get_world_2d().direct_space_state
			_wander_delay = WANDER_DELAY

			for i in range(20):
				var candidate = global_position + (Vector2.from_angle(randf() * 2 * PI) * randf_range(WANDER_DISTANCE / 10, WANDER_DISTANCE))

				var query = PhysicsPointQueryParameters2D.new()
				query.position = candidate

				if space_state.intersect_point(query).is_empty():
					nav_agent.target_position = candidate
					# print("new wander pos: ", candidate)

		else:
			return


	var target_pos = nav_agent.get_next_path_position()

	var new_velocity = global_position.direction_to(target_pos) * (WANDER_SPEED if target == null else SPEED)

	if nav_agent.avoidance_enabled:
		nav_agent.velocity = new_velocity
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)


	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
