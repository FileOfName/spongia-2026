extends Node2D

var player: Player
var _delay = 0

func _ready():
	$AnimatedSprite2D.play("fire")

func _process(delta: float) -> void:
	_delay = max(_delay - delta, 0)

	if _delay == 0 && player != null:
		_delay = randi_range(1, 5)
		player.heal(randi_range(10, 40))



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player.campfires.append(get_path())
		print("added", get_path())

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
