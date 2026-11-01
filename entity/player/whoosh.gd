class_name Whoosh
extends Node2D
## Swoosh effect in any color. Spawn it where damage is applied; it animates and frees itself.
##   ARC       - crescent that sweeps across a hit area (sword, axe)
##   RING      - full circle sweep around the player (axe spin)
##   STREAK    - speed lines along the +X axis (dagger dash)
##   SHOCKWAVE - circle expanding from start_extent to extent (mace slam)

enum Kind { ARC, RING, STREAK, SHOCKWAVE }

# Dagger speed lines: [distance from the center line in px, where along the dash it
# starts (0..1), how long it gets (0..1 of the dash)]. None runs through the middle.
const STREAK_LINES := [
	[-38.0, 0.10, 0.45],
	[-26.0, 0.35, 0.40],
	[26.0, 0.00, 0.40],
	[38.0, 0.25, 0.45],
]

var kind: Kind = Kind.ARC
var color := Color.WHITE
var extent := 60.0         # radius for ARC/RING/SHOCKWAVE, dash length for STREAK
var start_extent := 0.0    # SHOCKWAVE: the radius it starts at
var sweep := 2.1           # ARC width in radians (~120 degrees)
var duration := 0.18       # seconds the effect lasts

var progress := 0.0:       # 0 -> 1 over `duration`, redraws the effect every change
	set(value):
		progress = value
		queue_redraw()


## Creates a whoosh. Set .sweep / .duration / .start_extent on it afterwards if needed.
static func make(p_kind: Kind, p_angle: float, p_extent: float, p_color := Color.WHITE) -> Whoosh:
	var w := Whoosh.new()
	w.kind = p_kind
	w.rotation = p_angle
	w.extent = p_extent
	w.color = p_color
	return w


## Starts the animation and removes the node when it is finished.
func _ready() -> void:
	z_index = 10
	var tween := create_tween()
	tween.tween_property(self, "progress", 1.0, duration)
	tween.tween_callback(queue_free)


## Draws the current frame of the effect, fading out as `progress` goes to 1.
func _draw() -> void:
	var fade := 1.0 - progress
	var bright := Color(color, 0.9 * fade)
	var faint := Color(color, 0.45 * fade)

	match kind:
		Kind.ARC:
			var head := -sweep / 2.0 + sweep * progress
			var tail := maxf(-sweep / 2.0, head - sweep * 0.6)
			draw_arc(Vector2.ZERO, extent, tail, head, 16, bright, 6.0, true)
			draw_arc(Vector2.ZERO, extent - 9.0, tail, head, 16, faint, 3.0, true)
		Kind.RING:
			var head := TAU * progress
			var tail := maxf(0.0, head - TAU * 0.6)
			draw_arc(Vector2.ZERO, extent, tail, head, 32, bright, 6.0, true)
			draw_arc(Vector2.ZERO, extent - 10.0, tail, head, 32, faint, 3.0, true)
		Kind.STREAK:
			var grow := minf(progress * 3.0, 1.0)
			for line in STREAK_LINES:
				var x0: float = extent * line[1]
				var x1: float = x0 + extent * line[2] * grow
				draw_line(Vector2(x0, line[0]), Vector2(x1, line[0]), bright, 3.0, true)
		Kind.SHOCKWAVE:
			var radius := lerpf(start_extent, extent, progress)
			var alpha := 1.0 - progress * progress     # stays visible until near the end
			draw_circle(Vector2.ZERO, radius, Color(color, 0.12 * alpha))
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(color, 0.9 * alpha), 5.0, true)
