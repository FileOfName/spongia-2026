class_name Player
extends Entity

@export var SPEED: float = 280
@export var ATTACK_SECONDS: float = 0.3

var attack_cooldown: float = 0

func death():
	# dont remove self on death
	pass

func _process(delta: float) -> void:
	if attack_cooldown == 0 and Input.is_action_just_pressed("attack"):
		$SwordHitBox/CollisionShape2D.disabled = false
		attack_cooldown = ATTACK_SECONDS

	# I know, timers, who cares
	attack_cooldown -= delta

	if attack_cooldown < 0:
		attack_cooldown = 0
		$SwordHitBox/CollisionShape2D.disabled = true

func _physics_process(_delta: float) -> void:
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

	#rotate sword collider
	if direction:
		$SwordHitBox.rotation = direction.angle()

	move_and_slide()


func _on_sword_hit_box_body_entered(body: Node2D) -> void:
	if body == self:
		return
	if body is Entity:
		body.damage(30)
	print(body)
