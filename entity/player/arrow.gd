class_name Arrow
extends Area2D
## Flies from the shooter to the clicked point along a slightly lifted (ballistic) path.
## Damages the first Entity it touches; sticks into walls / the ground and fades out.

const SPEED := 650.0
const MIN_RANGE := 60.0
const MAX_RANGE := 700.0
const ARC_HEIGHT_RATIO := 0.15   # peak lift as a fraction of the distance ("slight" curve)

var shooter: Node
var damage := 25
var color := Color.WHITE         # color of the arrow head and feathers

var _start := Vector2.ZERO
var _end := Vector2.ZERO
var _lift := 0.0
var _flight_time := 1.0
var _t := 0.0
var _landed := false


## Sets where the arrow starts and where it lands (clamped to the min/max range). Call before add_child.
func setup(p_shooter: Node, from: Vector2, to: Vector2, p_damage: int) -> void:
	shooter = p_shooter
	damage = p_damage
	var dir := (to - from).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	var dist := clampf(from.distance_to(to), MIN_RANGE, MAX_RANGE)
	_start = from
	_end = from + dir * dist
	_flight_time = dist / SPEED
	_lift = dist * ARC_HEIGHT_RATIO


## Builds the collision circle and puts the arrow at its start position.
func _ready() -> void:
	z_index = 5
	collision_layer = 0   # nothing needs to detect the arrow
	collision_mask = 1    # <- set to the layers of your enemies AND walls
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)
	global_position = _start


## Moves the arrow along its curved path and turns it to point along the flight direction.
func _physics_process(delta: float) -> void:
	if _landed:
		return
	_t += delta / _flight_time
	var k := minf(_t, 1.0)
	var p := _start.lerp(_end, k)
	p.y -= 4.0 * _lift * k * (1.0 - k)         # parabola, peaks halfway
	rotation = (p - global_position).angle()
	global_position = p
	if _t >= 1.0:
		_land()


## Hits an Entity (damage, arrow disappears) or sticks into anything else (walls).
func _on_body_entered(body: Node2D) -> void:
	if _landed or body == shooter:
		return
	if body is Entity:
		body.damage(damage)
		queue_free()
	else:
		_land()


## Stops the arrow where it is, then fades it out and removes it.
func _land() -> void:
	_landed = true
	set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_interval(0.4)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


## Draws a simple arrow pointing along +X: brown shaft, head and feathers in the item's color.
func _draw() -> void:
	draw_line(Vector2(-16, 0), Vector2(6, 0), Color(0.55, 0.38, 0.20), 2.0)
	draw_colored_polygon(PackedVector2Array([Vector2(12, 0), Vector2(5, -3.5), Vector2(5, 3.5)]), color)
	draw_line(Vector2(-16, 0), Vector2(-20, -3), color, 1.5)
	draw_line(Vector2(-16, 0), Vector2(-20, 3), color, 1.5)
