extends TileMapLayer
#mal by spawnovat iba ak nie je savegame.txt

const ENEMY_SCENES := [
	"res://entity/enemy/dwarf.tscn",
	"res://entity/enemy/elf.tscn",
	"res://entity/enemy/goblin.tscn",
]
const SPAWN_TILES := [Vector2i(11, 0), Vector2i(11, 1), Vector2i(11, 3), Vector2i(11, 5)]   # atlas cs

@export var random_spawns = 10            # nahodni jednotlivci
@export var patrolky = 3
@export var party_size = Vector2i(2, 6)
@export var base_count = 5
@export var base_size = Vector2i(4, 7)
@export var group_radius = 150.0          # ako daleko od stredu -> px
const MAP_FILE := "map.tscn"
@export var _cells: Array[Vector2] = []            # kde sa mozu (aby sa nestala chyba s vonkajsim spawnom)





#nacitanie
func _spawn() -> void:
	var save: Variant = Player.read_save()
	if save != null and save.has("enemies"):
		_restore(save["enemies"])
	else:
		_spawn_new()


func _restore(saved: Array) -> void:
	var parties := {}
	for d in saved:
		if not ResourceLoader.exists(d["scene"]):
			continue
			var enemy := _make_enemy(d["position"], d["scene"])
			var party: EnemyParty = null
			if d["party"] >= 0:
				if not parties.has(d["party"]):
					parties[d["party"]] = EnemyParty.new()
					parties[d["party"]].id = d["party"]
					party = parties[d["party"]]
					enemy.setup(d["base"], party)
					enemy.from_dict(d)

#prinovej
#zozber
func _ready() -> void:
	_setup()
func _setup() ->void:
	for cell in get_used_cells():
		if get_cell_atlas_coords(cell) in SPAWN_TILES:
			_cells.append(to_global(map_to_local(cell)))
	if _cells.is_empty():
		push_warning("Nenajdeee tily")
		for cell in get_used_cells():
			_cells.append(to_global(map_to_local(cell)))
	_spawn_when_map_loaded()
func _spawn_new() -> void:
	if _cells.is_empty():
		push_warning("No spawnable tiles found")
		return
	for i in random_spawns:
		_make_enemy(_cells.pick_random())
	for i in patrolky:
		var party := EnemyParty.new()
		party.id = i
		_make_group(randi_range(party_size.x, party_size.y), false, party)
	for i in base_count:
		_make_group(randi_range(base_size.x, base_size.y), true)


func _make_group(size: int, base: bool, party: EnemyParty = null) -> void:
	size = maxi(size, 1)
	var center: Vector2 = _cells.pick_random()
	var near = _cells.filter(func(c): return c.distance_to(center) <= group_radius)
	var buffed_one := randi_range(0, size - 1)
	for i in size:
		var enemy := _make_enemy(near.pick_random() + Vector2(randf_range(-8, 8), randf_range(-8, 8)))
		enemy.setup(base, party)
		if i == buffed_one:
			enemy.make_buffed()


func _make_enemy(pos: Vector2, scene_path := "") -> Enemy:
	if scene_path == "":
		scene_path = ENEMY_SCENES.pick_random()
	var enemy: Enemy = load(scene_path).instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = pos
	return enemy
	
func _spawn_when_map_loaded() -> void:
	await get_tree().process_frame
	var scene = get_tree().current_scene
	if scene == null or scene.scene_file_path.get_file() != MAP_FILE:
		print("teraz tiezzjavne")
	_spawn()
