extends CanvasLayer

const SKIP_TIME := 0.5
const SKIP_COUNT := 5
@export var NEXT_SCENE: PackedScene


@onready var content: VBoxContainer = $Content
@onready var button: Button = $Button

@onready var _skip_time := -SKIP_TIME * 4
var _skip_count := 0
var _tween: Tween;

func _get_animating_children():
	return content.get_children() + [button]


func _ready() -> void:
	for child in _get_animating_children():
		if child is CanvasItem:
			child.visible = false
	animate()

func animate():
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)

	for child in _get_animating_children():
		if child is CanvasItem:
			child.visible = true
			child.modulate = Color(1, 1, 1, 0)
			_tween.tween_property(child, "modulate", Color(1, 1, 1, 1), 3)

func skip():
	_tween.kill()
	for child in _get_animating_children():
		if child is CanvasItem:
			child.visible = true
			child.modulate = Color(1, 1, 1, 1)

func _unhandled_key_input(event: InputEvent) -> void:
	_skip_count += 1

func _process(delta: float) -> void:
	if _skip_time < 0:
		_skip_time += delta
		if _skip_time > 0:
			_skip_time = 0
		return

	if _skip_count > 0:
		_skip_time += delta
		if _skip_time > SKIP_TIME:
			if _skip_count > SKIP_COUNT:
				print("Skipp")
				skip()
			_skip_count = 0
			_skip_time = 0


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(NEXT_SCENE)
