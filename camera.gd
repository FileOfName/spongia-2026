extends Camera2D

@export var player: Player
@export var SPEED = 5.0

func _ready() -> void:
	position = player.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = lerp(position, player.position, SPEED * delta)
