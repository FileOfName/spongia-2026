class_name Entity

extends CharacterBody2D

@export var SPRITE: Sprite2D
@export var MAX_HEALTH: float = 100
@export var INVULNERABILITY_SECONDS: float = 0.2

var _invulnerability: float = 0
var _heal_tween: Tween = null;

var _health: float = MAX_HEALTH
var health:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, MAX_HEALTH)
		# the entity can technically die multiple times, will fix if its a problem
		if _health == 0:
			death()
		health_changed.emit(_health)

func is_invulnerable() -> bool:
	return _invulnerability > 0

func damage(amount: int):
	if is_invulnerable():
		return
	_invulnerability = INVULNERABILITY_SECONDS
	health -= amount

	# Red flash

	SPRITE.modulate = Color(1, 0.5, 0.5)
	# dont animate the red flash if we are dead
	if health == 0:
		return

	var tween = create_tween()
	tween.tween_property(SPRITE, "modulate", Color(1,1,1), INVULNERABILITY_SECONDS).set_trans(Tween.TRANS_SINE)


func heal(amount: int):
	health += amount

	# Green flash
	if _heal_tween != null:
		_heal_tween.kill()

	SPRITE.modulate = Color(0.5, 1, 0.6)
	_heal_tween = create_tween()
	_heal_tween.tween_property(SPRITE, "modulate", Color(1,1,1), 0.4).set_trans(Tween.TRANS_SINE)

func death():
	var tween = create_tween()

	tween.tween_property(SPRITE, "rotation_degrees", SPRITE.rotation_degrees - 90, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(SPRITE, "modulate", Color(1, 0.5, 0.5, 0), 0.3).set_trans(Tween.TRANS_QUINT)

	tween.finished.connect(queue_free)

func tick_invulnerability(delta: float):
	_invulnerability = max(0, _invulnerability - delta)

func _process(delta: float) -> void:
	tick_invulnerability(delta)

signal health_changed(health: int)
