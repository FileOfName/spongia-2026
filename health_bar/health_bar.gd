extends TextureProgressBar

@export var entity: Entity;

var _tween: Tween = null;

func _ready() -> void:
	entity.health_changed.connect(update_health_bar)

	max_value = entity.MAX_HEALTH
	value = entity.health

func update_health_bar(health):
	if _tween != null:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "value", health, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
