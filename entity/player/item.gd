class_name Item
extends RefCounted

const testy := {
	"mec": {
		"display_name": "Sword",
		"typ" : "mec",
		"color": Color(0.7, 0.75, 0.85),
		"cooldown": 0.35,
		"damage": 30,
		"hit_size": Vector2(72, 56),
		"whoosh_arc": 120.0
	},
	"sek": {
		"display_name": "Axe",
		"typ" : "sekera",
		"color": Color(0.8, 0.5, 0.35),
		"cooldown": 0.8,
		"damage": 45,
		"hit_size": Vector2(52, 40),
		"whoosh_arc": 80.0,
		"cas": 1,
		"spin_rotations" : 7
	},
	"luk": {
		"display_name": "Bow",
		"typ" : "luk",
		"color": Color(0.65, 0.5, 0.3),
		"cooldown": 0.6,
		"damage": 25
	},
	"dyka": {
		"display_name": "Dagger",
		"typ" : "dyka",
		"color": Color(0.55, 0.75, 0.85),
		"cooldown": 0.5,
		"damage": 20
	},
	"palcat": {
		"display_name": "Mace",
		"typ": "palcat",
		"color": Color(0.6, 0.6, 0.65),
		"cooldown": 1.2,
		"damage": 70,
		"odskoc": 30,
		"odskocodpocet":80,
		"tlac":40,
		"otlac":55,
		"zasek":1.8
	},
	"kriak": {
		"display_name": "Herb",
		"typ": "idkasinetreba",
		"color": Color(0.35, 0.75, 0.35),
		"cooldown": 0.5,
		"max_stack": 10,
		"heal": 25
	},
	"coin": {
		"display_name": "Coin"
	}
}

var type := ""                     # "sword", "axe", ... (a key of DEFAULTS)
var count := 1                     # how many are in this stack
var max_stack := 1                 # more than 1 = stackable (herbs)
var display_name := "Item"
var typ := "idk"
var color := Color.WHITE           # color of the slot in the inventory bar
var whoosh_color := Color.WHITE    # color of the swing / arrow / slam effects
var cooldown := 0.5
var damage := 10
var cas := 0.7

# melee (sword, axe)
var hit_size := Vector2(60, 100)    # starts at the player: length toward the cursor x width # MISKO increasol som hit size - radko
var whoosh_arc := 120.0            # width of the swing animation, in degrees

var spin_cooldown :=8
var spin_rotations := 7
var spin_radius := 85.0
var spin_damage := 10	#bacha, pocas kazdeho otocenia
var spin_speed_mult := 1.4         # zrychlenie
var spin_damage_taken_mult := 0.5  # brnko -> tiez zatial nefunguje. nizsie -> lepsie

# dash (dagger)	# nie ze by to fungovalo :/
var dash_distance := 180.0
var dash_speed := 900.0
var dash_radius := 24.0

# palalallalalalalalalaaacaaaat
var slam_reach := 50.0             # distance in front of the player where it lands
var slam_start_radius := 10.0 #iba vizualne
var slam_radius := 60.0

#odskok
var odskoc=0
var odskocodpocet=0
var tlac=0
var otlac=0
var zasek=0


var heal := 30

var overrides := {}

#help by AI, most was scrapped, but eitherway

func _init(p_type := "", p_overrides := {}) -> void:
	type = p_type
	if not testy.has(p_type):
		push_error("Unknown item type: %s" % p_type)
		return
	for key in testy[p_type]:
		set(key, testy[p_type][key])
	for key in p_overrides:
		if key in self:
			set(key, p_overrides[key])
		else:
			push_error("Item has no variable called '%s'" % key)
	overrides = p_overrides.duplicate()
	overrides.erase("count")


func same_as(other: Item) -> bool:
	return type == other.type and overrides == other.overrides
func copy(amount: int) -> Item:
	var item := Item.new(type, overrides)
	item.count = amount
	return item


## Turns the item into plain data for the save file.
func to_dict() -> Dictionary:
	return {"type": type, "count": count, "overrides": overrides}


## Rebuilds an item from saved data (see to_dict).
static func from_dict(data: Dictionary) -> Item:
	var item := Item.new(data.get("type", ""), data.get("overrides", {}))
	item.count = data.get("count", 1)
	return item
