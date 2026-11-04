extends Node2D

@export var PRICE = 20

var _items = ["luk", "mec", "palcat", "sek"]
var _player: Player = null;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _player != null and Input.is_action_just_pressed("attack") and _player.inventory.coins > PRICE:
		_player.inventory.coins -= PRICE
		var rand = randi_range(1, 5)
		if rand == 1:
			for i in range(randi_range(0, 40)):
				Pickup.drop(get_parent().get_parent(), global_position, Item.new("coin"), 0, Vector2.from_angle(rotation + randf_range(-0.4, 0.4)) * 100)
		else:
			var item_name = _items[rand - 2]
			print(item_name)
			var default = Item.testy[item_name]
			var item = Item.new(item_name, {"damage": default["damage"] + randi_range(-5, 40), "cooldown": default["cooldown"] + randf_range(-0.25, 0.1)})
			Pickup.drop(get_parent().get_parent(), global_position, item, 0, Vector2.from_angle(rotation + randf_range(-0.4, 0.4)) * 100)




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		_player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		_player = null
