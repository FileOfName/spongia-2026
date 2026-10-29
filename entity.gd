class_name Entity

extends CharacterBody2D

@export var MAX_HEALTH: float = 100
@export var INVULNERABILITY_SECONDS: float = 2

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

func damage(amount):
    if is_invulnerable():
        return
    _invulnerability = INVULNERABILITY_SECONDS
    health -= amount

func heal(amount):
    health += amount

func tick_invulnerability(delta: float):
    _invulnerability = max(0, _invulnerability - delta)

func _process(delta: float) -> void:
    tick_invulnerability(delta)

signal health_changed(health)
signal death()

