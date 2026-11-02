extends Control

@onready var goblin: CharacterBody2D = $Goblin
@onready var content: VBoxContainer = $Content
@onready var credits: VBoxContainer = $Credits

var _crossfade_tween: Tween = null

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(goblin, "rotation_degrees", 30, 5).from(-30).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(goblin, "rotation_degrees", -30, 5).from(30).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scene.tscn")

func _on_load_game_pressed() -> void:
	print("MIskooooo")
	get_tree().change_scene_to_file("res://main_scene.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	_crossfade(content, credits)


func _on_back_pressed() -> void:
	_crossfade(credits, content)

func _crossfade(from: Control, to: Control, time: float = 0.5, ease: int = Tween.EASE_IN_OUT, trans: int = Tween.TRANS_QUAD):
	from.modulate = Color(1, 1, 1, 1)
	from.visible = true

	to.modulate = Color(1, 1, 1, 0)
	to.visible = true

	if _crossfade_tween != null:
		_crossfade_tween.kill()

	_crossfade_tween = create_tween().set_parallel(true).set_ease(ease).set_trans(trans)
	_crossfade_tween.tween_property(from, "modulate", Color(1, 1, 1, 0), time)
	_crossfade_tween.tween_property(to, "modulate", Color(1, 1, 1, 1), time)

	_crossfade_tween.finished.connect(func (): from.visible = false)
