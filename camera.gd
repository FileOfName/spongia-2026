extends Camera2D

@export var target: Node2D
@export var SPEED = 5.0

func _ready() -> void:
	position = target.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = lerp(position, target.position, SPEED * delta)
