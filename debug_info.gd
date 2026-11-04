extends Control

@onready var coin_label: Label = $CoinLabel
@export var player: Player;

var debug = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = debug

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		debug = !debug
		visible = debug
	if !debug:
		return
	coin_label.text = str(player.inventory.coins) + " coins"


func _on_coin_button_pressed() -> void:
	var coin = Item.new("coin")
	coin.count = 1000
	player.inventory.add(coin)

func _on_kill_btn_pressed():
	player.health = 0

func _on_outro_btn_pressed():
	var ring = Item.new("prsten")
	ring.count = 64
	player.inventory.add(ring)
	# get_tree().change_scene_to_file("res://assets/ui/intro/outro.tscn")
