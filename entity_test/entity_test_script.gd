extends Node2D


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label2.text = "Inv: " + str($CharacterBody2D._invulnerability)


func _on_character_body_2d_health_changed(health: int) -> void:
	$Label.text = "HEALTH " + str(health)


func _on_character_body_2d_death() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	$CharacterBody2D.heal(20)


func _on_button_2_pressed() -> void:
	$CharacterBody2D.damage(20)
