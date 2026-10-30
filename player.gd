class_name Player
extends Entity

@export var SPEED: float = 280

func death():
    # dont remove self on death
    pass

func _physics_process(delta: float) -> void:
    var x_direction = Input.get_axis("move_left", "move_right")
    var y_direction = Input.get_axis("move_up", "move_down")
    var direction = Vector2(x_direction, y_direction).normalized()

    var new_velocity = direction * SPEED

    # copied from the CharacterBody2D template - not sure if its necessary
    if not new_velocity.x:
        new_velocity.x = move_toward(velocity.x, 0, SPEED)
    if not new_velocity.y:
        new_velocity.y = move_toward(velocity.y, 0, SPEED)

    velocity = new_velocity

    move_and_slide()

