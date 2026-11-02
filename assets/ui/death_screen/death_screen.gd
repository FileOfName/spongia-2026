extends CanvasLayer

@onready var background: TextureRect = $Background
@onready var content: VBoxContainer = $Content


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_respawn_pressed() -> void:
	#MISKO YOUR CODE HERE DANKEE
	pass # Replace with function body.

func _on_main_menu_pressed() -> void:
	print("not made")

func _on_quit_pressed() -> void:
	get_tree().quit()

func show_death_screen():
	content.modulate = Color(1, 1, 1, 0)
	background.modulate = Color(1, 1, 1, 0)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(content, "modulate", Color(1, 1, 1, 1), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)


	show()

func _on_player_on_death() -> void:
	pass # Replace with function body.
