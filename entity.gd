class_name Entity

extends CharacterBody2D

@export var sprite: Sprite2D
@export var MAX_HEALTH: float = 100
@export var INVULNERABILITY_SECONDS: float = 0.2

var _heal_tween: Tween = null;

var _health: float = MAX_HEALTH
var _invulnerability: float = 0

var health:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, MAX_HEALTH)
		health_changed.emit(_health)
		if _health == 0:
			death.emit()

func is_invulnerable() -> bool:
	return _invulnerability > 0

func damage(amount: int):
	if is_invulnerable():
		return
	_invulnerability = INVULNERABILITY_SECONDS
	health -= amount

	# Red flash

	sprite.modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1,1,1), INVULNERABILITY_SECONDS).set_trans(Tween.TRANS_SINE)


func heal(amount: int):
	health += amount

	# Green flash
	if _heal_tween != null:
		_heal_tween.kill()

	sprite.modulate = Color(0.2, 1, 0)
	_heal_tween = create_tween()
	_heal_tween.tween_property(sprite, "modulate", Color(1,1,1), 0.4).set_trans(Tween.TRANS_SINE)

func tick_invulnerability(delta: float):
	_invulnerability = max(0, _invulnerability - delta)

func _process(delta: float) -> void:
	tick_invulnerability(delta)

signal health_changed(health: int)
signal death()
