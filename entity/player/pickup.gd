class_name Pickup
extends Area2D
## An item lying on the ground, drawn as a small square in the item's color.
## Walk over it to pick it up. It keeps all of its custom stats and its stack count.

var item: Item
var _delay := 0.0   # seconds before it can be picked up (so a dropped item isn't taken straight back)

var _pickup_tween: Tween = null

## Puts an item on the ground. `world` is the node it is added to (use get_parent() of the
## player/enemy, i.e. the level), `delay` is how long it can't be picked up.
static func drop(world: Node, pos: Vector2, p_item: Item, delay := 0.0) -> Pickup:
	var pickup := Pickup.new()
	pickup.item = p_item
	pickup._delay = delay
	world.add_child(pickup)
	pickup.global_position = pos
	return pickup


## Gives the pickup its collision circle. It only looks for bodies on layer 1 (where the player is).
func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	add_child(shape)


## After the delay, gives the item to the player standing on it. What doesn't fit stays on the ground.
func _physics_process(delta: float) -> void:
	if _pickup_tween != null:
		return

	_delay -= delta
	if _delay > 0.0:
		return
	for body in get_overlapping_bodies():
		if body is Player:
			var left: int = body.inventory.add(item)
			if left == 0:
				_pickup_tween = create_tween()
				print(_pickup_tween)
				_pickup_tween.set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				_pickup_tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
				_pickup_tween.tween_property(self, "position", body.global_position, 0.2)
				_pickup_tween.finished.connect(queue_free)
			elif left != item.count:
				item.count = left
				queue_redraw()
			return


## Draws the item as a colored square with its name (and stack size) above it.
func _draw() -> void:
	var label := item.display_name
	if item.max_stack > 1:
		label += " x%d" % item.count
	if item.texture:
		var rect = Rect2(-12, -12, 24, 24)

		var texture_size = item.texture.get_size()
		var size_factor = rect.size / (max(texture_size.x , texture_size.y))
		texture_size *= size_factor
		var texture_position = rect.get_center() - (texture_size / 2)

		draw_texture_rect(item.texture, Rect2(texture_position, texture_size), false)
	else:
		draw_rect(Rect2(-12, -12, 24, 24), item.color)
		draw_rect(Rect2(-12, -12, 24, 24), Color(0, 0, 0, 0.6), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-40, -18), label, HORIZONTAL_ALIGNMENT_CENTER, 80, 12)
