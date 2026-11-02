extends Control

@export var player: Player

@onready var coin_label: Label = $Coins
@onready var damage_label: Label = $VBoxContainer/Label
@onready var cooldown_label: Label = $VBoxContainer/Label2

var displayed_coins  := 0
var last_coins = 0
var _coins_tween: Tween = null

# i know, signals, who cares
func _ready() -> void:
	last_coins = player.inventory.coins
	displayed_coins = player.inventory.coins
	damage_label.text = ""
	cooldown_label.text = ""

func _process(delta: float) -> void:
	if last_coins != player.inventory.coins:
		last_coins = player.inventory.coins
		if _coins_tween != null:
			_coins_tween.kill()
		_coins_tween = create_tween()

		_coins_tween.tween_property(self, "displayed_coins", player.inventory.coins, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	coin_label.text = str(displayed_coins)

	if player._held == null:
		damage_label.text = ""
		cooldown_label.text = ""
	else:
		damage_label.text = "DAMAGE: " + str(player._held.damage)
		cooldown_label.text = "COOLDOWN: " + str(snapped(player._held.cooldown, 0.01))
