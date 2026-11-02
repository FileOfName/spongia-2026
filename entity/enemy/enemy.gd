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
@export var MAX_COINS = 10
@export var MIN_COINS = 2
@export var HAS_BOW = false

var odskoc := 0.0
var odskocodpocet := 0.0
var odskocpriestor := Vector2.ZERO
var _stuck_time := 0.0

var is_chasing = false
var target: Player = null
var _wander_delay = 0
var _attack_cooldown = 0
var _weapon_rotation = 0
var _keep_distance = false
@onready var weapon_center: Node2D = $WeaponCenter
@onready var weapon_sprite: Sprite2D = $WeaponCenter/Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var hit_area: Area2D = $HitArea
func hod_stuck(kolko: float, okolko: float, kade: Vector2, cas: float) -> void:
	odskoc = kolko
	odskocodpocet = okolko
	odskocpriestor = kade.normalized()
	_stuck_time = cas

func _ready() -> void:
	var shape = $CollisionShape2D.shape
	var new_radius = 0

	if shape is CircleShape2D:
		new_radius = shape.radius
	elif shape is CapsuleShape2D:
		new_radius = max(shape.radius, shape.height)
	$NavigationAgent2D.radius = new_radius

func _on_enter_area_entered(body: Node2D) -> void:
	if body is Player:
		target = body

func _on_exit_area_exited(body: Node2D) -> void:
	if body is Player:
		target = null
		nav_agent.target_position = global_position
		_keep_distance = false

func _on_hit_area_entered(body: Node2D) -> void:
	if body is Player:
		if HAS_BOW:
			nav_agent.target_position = global_position
			_keep_distance = true
			_shoot(body.global_position)
			return
		_hit(body)

func _on_hit_area_exited(body: Node2D) -> void:
	if body is Player && HAS_BOW:
		nav_agent.target_position = body.global_position
		_keep_distance = false
		return

func _process(delta: float) -> void:
	super._process(delta)
	_wander_delay = max(_wander_delay - delta, 0)
	_attack_cooldown -= delta
	if _attack_cooldown < 0:
		_attack_cooldown = 0
		if HAS_BOW && target != null:
			_shoot(target.global_position)
		else:
			for b in hit_area.get_overlapping_bodies():
				if b is Player:
					_hit(b)

	weapon_center.rotation = wrapf(lerp_angle(weapon_center.rotation, _weapon_rotation, 5 * delta), 0 , 2 * PI)

	if !HAS_BOW:
		weapon_sprite.rotation = 2.6 if weapon_center.rotation > PI/2 && weapon_center.rotation < 3 * PI / 2 else 0.6

func _hit(player: Player):
	if health == 0 || _attack_cooldown != 0 || _stuck_time > 0.0:
		return
	player.damage(DAMAGE)
	_attack_cooldown = ATTACK_COOLDOWN


	var whoosh := Whoosh.make(Whoosh.Kind.ARC, get_angle_to(player.global_position), $HitArea/CollisionShape2D.shape.radius, WHOOSH_COLOR)
	whoosh.sweep = deg_to_rad(WHOOSH_ARC)
	_show_whoosh(whoosh)

func _shoot(target) -> void:
	if health == 0 || _attack_cooldown != 0 || _stuck_time > 0.0:
		return
	_attack_cooldown = ATTACK_COOLDOWN
	var arrow = Arrow.new()
	arrow.setup(self, global_position, target, DAMAGE)
	arrow.color = WHOOSH_COLOR
	get_parent().add_child(arrow)

func damage(amount: int):
	super.damage(amount)

func _death_anim_finished():
	super._death_anim_finished()
	for i in range(randi_range(MIN_COINS, MAX_COINS)):
		Pickup.drop(get_parent(), global_position, Item.new("coin"), 0, Vector2.from_angle(randf() * 2 * PI) * 50)

func _physics_process(delta: float) -> void:
	if health == 0:
		return
	if odskoc > 0.0 or _stuck_time > 0.0:
		velocity = odskocpriestor * odskoc
		odskoc = maxf(odskoc - odskocodpocet * delta, 0.0)
		_stuck_time = maxf(_stuck_time - delta, 0.0)
		move_and_slide()
		return
	if target != null:
		if HAS_BOW:
			if _keep_distance:
				nav_agent.target_position = global_position
			else:
				print("updated?")
				nav_agent.target_position = target.global_position
		else:
			nav_agent.target_position = target.global_position
		_weapon_rotation = (target.position - global_position).angle()

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

	SPRITE.flip_h = velocity.x < 0
	if target == null:
		_weapon_rotation = PI if velocity.x < 0 else 0.0

	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
