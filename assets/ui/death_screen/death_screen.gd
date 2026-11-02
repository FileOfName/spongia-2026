extends CanvasLayer

@onready var background: TextureRect = $Background
@onready var content: VBoxContainer = $Content
#const EnemySpawner = preload("res://map/enemy_spawner.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_respawn_pressed() -> void:
	# TEMPORARY
	var player = get_parent().get_node("Player")
	player.inventory.coins = 0
	#var spawner = EnemySpawner.new()
	#spawner._setup()
	#player.save_game()
	get_tree().change_scene_to_file("res://main_scene.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/ui/main_menu/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func show_death_screen():
	set_buttons_disabled(true)
	content.modulate = Color(1, 1, 1, 0)
	background.modulate = Color(1, 1, 1, 0)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(content, "modulate", Color(1, 1, 1, 1), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

	tween.finished.connect(func (): set_buttons_disabled(false))
	show()

func set_buttons_disabled(value: bool):
	for child in content.get_children():
		if child is Button:
			child.disabled = value
