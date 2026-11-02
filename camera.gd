extends Camera2D

@export var target: Node2D
@export var SPEED = 5.0
@export var POSITION_CLAMP = false
@export var MIN_TOP_LEFT: Vector2
@export var MAX_BOTTOM_RIGHT: Vector2

func _ready() -> void:
	position = target.position
	_make_icons()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = lerp(position, _clamp_position(target.position), SPEED * delta)

func _clamp_position(position: Vector2) -> Vector2:
	var global_viewport_center = get_viewport_rect().size / zoom / 2

	# var center = get_screen_center_position()
	var min_top_left = MIN_TOP_LEFT + global_viewport_center
	var max_bottom_right = MAX_BOTTOM_RIGHT - global_viewport_center

	return Vector2(clamp(position.x, min_top_left.x, max_bottom_right.x), clamp(position.y, min_top_left.y, max_bottom_right.y))

#na prsten
const kolko = 5
const velkost = Vector2(20, 22)
const odskok = 16.0

# od AI
const GRAY_SHADER := """
shader_type canvas_item;
void fragment() {
	float g = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
	COLOR.rgb = vec3(g);
}
"""
var textura=load("res://assets/ui/prsten.png")

var kolko_farebne = 0:
	set(value):
		kolko_farebne = clampi(value, 0, kolko)
		_update_icons()
var _kolko: Array[Sprite2D] = []
var _gray_material: ShaderMaterial
func _make_icons() -> void:
	var shader = Shader.new()
	shader.code = GRAY_SHADER
	_gray_material = ShaderMaterial.new()
	_gray_material.shader = shader

	var layer := CanvasLayer.new()
	add_child(layer)

	var tex_size = textura.get_size()
	var fit = minf(velkost.x / tex_size.x, velkost.y / tex_size.y)

	for i in kolko:
		var icon = Sprite2D.new()
		icon.texture = textura
		icon.scale = Vector2(fit, fit)
		layer.add_child(icon)
		_kolko.append(icon)

	_place_icons()
	get_viewport().size_changed.connect(_place_icons)
	_update_icons()

func _place_icons() -> void:
	var top := (get_viewport_rect().size.y - kolko * velkost.y) / 2.0
	for i in _kolko.size():
		_kolko[i].position = Vector2(odskok + velkost.x / 2.0, top + (i + 0.5) * velkost.y)

func _update_icons() -> void:
	for i in _kolko.size():
		_kolko[i].material = null if i < kolko_farebne else _gray_material
