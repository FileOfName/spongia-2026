class_name Player
extends Entity

@export var SPEED: float = 280

var inventory := Inventory.new()
var campfires = []
var attack_cooldown = 0.0
var spin_cooldown = 0.0

var _held: Item
var _spin_requested := false
var _speed_mult := 1.0         # tmp, meni pocas tocenia
var _brnko = 1.0	#nopefunguje
var _cakanka = 0.0          # cas kolko je zaseknuty
var _t_cas =0.0
var _rachnute=[]
var _slam_center := Vector2.ZERO
var _otocas=0.0
var odskoc=0
var odskocpriestor=Vector2.ZERO
var odskocodpocet=0


func _ready() -> void:

	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(inventory)

	load_game()

func _unhandled_input(event: InputEvent) -> void:
	if health == 0:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_G:
			_drop_item()
			return
		var slot: int = event.physical_keycode - KEY_1
		if slot < 0 or slot >= Inventory.SLOTS:
			slot = event.physical_keycode - KEY_KP_1
		if slot >= 0 and slot < Inventory.SLOTS:
			inventory.select(slot)
	elif event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				inventory.select(inventory.selected - 1)
			MOUSE_BUTTON_WHEEL_DOWN:
				inventory.select(inventory.selected + 1)
			MOUSE_BUTTON_RIGHT:
				_spin_requested = true

func _physics_process(delta: float) -> void:
	if health == 0:
		return

	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	spin_cooldown = maxf(spin_cooldown - delta, 0.0)
	_cakanka = maxf(_cakanka - delta, 0.0)

	var held := inventory.selected_item()
	if held != _held:
		_held = held
		if _held!=null:
			attack_cooldown = _held.cooldown-0.5
		if _t_cas > 0.0:
			_zastav_stav()
	if _held!=null:
		$SwordHitBox/Sprite2D.texture=load("res://assets/zbrane/"+_held.typ+".png")
		#namierenie:
		var tmp =_aim_angle()
		$SwordHitBox.rotation=tmp
		if _held.typ!="luk":
			if _held.typ!="luk":
				if tmp>1.6 or tmp<-1.6:
					$SwordHitBox/Sprite2D.rotation=2.6
				else:
					$SwordHitBox/Sprite2D.rotation=0.6
			#dodat ak bude cas swing animaciu
		else:
			$SwordHitBox/Sprite2D.rotation=0.0
		if _t_cas > 0.0:
			if _held.typ=="sekera":
				_t_cas -= delta
				_otocas-=delta
				$Sprite2D.rotation += TAU / _held.cas * delta * _held.spin_rotations
				if _otocas<=0.0:
					_otocas=_held.cas/_held.spin_rotations
					_rachnute.clear()
					var ring := Whoosh.make(Whoosh.Kind.RING, 0.0, _held.spin_radius, _held.whoosh_color)
					_show_whoosh(ring)
					var supa := CircleShape2D.new()
					supa.radius = _held.spin_radius
					_hit_shape(supa, Transform2D(0.0, global_position), _held.spin_damage, _rachnute)
				if _t_cas<=0:
					_zastav_stav()
			if _held.typ=="dyka":
				_t_cas -= delta
				if _t_cas<=0:
					_zastav_stav()

		var busy := _cakanka > 0.0 or _t_cas > 0.0
		if attack_cooldown == 0.0 and not busy:
			if _spin_requested and spin_cooldown == 0.0 and held.cas > 0.0:
				_start_spin()
			elif Input.is_action_just_pressed("attack"):
				_use()
		_spin_requested = false
	else:
		$SwordHitBox/Sprite2D.texture = null
	var direction := Vector2.ZERO
	if _cakanka <= 0.0:
		direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()

	var new_velocity := direction * SPEED * _speed_mult

	# copied from the CharacterBody2D template - not sure if its necessary
	# asi nie je, ale mozno to zastavi bugy
	if not new_velocity.x:
		new_velocity.x = move_toward(velocity.x, 0, SPEED)
	if not new_velocity.y:
		new_velocity.y = move_toward(velocity.y, 0, SPEED)
	new_velocity+=odskocpriestor*odskoc*-1
	odskoc=maxf(odskoc - odskocodpocet*delta, 0.0)
	velocity = new_velocity
	move_and_slide()

func _use() -> void:
	attack_cooldown = _held.cooldown
	odskoc=_held.odskoc
	odskocpriestor=Vector2.from_angle(_aim_angle())
	odskocodpocet=_held.odskocodpocet
	match _held.typ:
		"mec": _melee()
		"sekera": _melee()
		"luk": _shoot()
		"palcat": _slam()
		"idkasinetreba": _heal()	#indeed bolo treba

func _melee() -> void:
	var angle = _aim_angle()
	var center = global_position
	var supa = RectangleShape2D.new()
	supa.size = _held.hit_size
	_rachnute.clear()
	_hit_shape(supa, Transform2D(angle, center), _held.damage, _rachnute)

	var whoosh := Whoosh.make(Whoosh.Kind.ARC, angle, _held.hit_size.x, _held.whoosh_color)
	whoosh.sweep = deg_to_rad(_held.whoosh_arc)
	_show_whoosh(whoosh)

func _shoot() -> void:
	var arrow = Arrow.new()
	arrow.setup(self, global_position, get_global_mouse_position(), _held.damage)
	arrow.color = _held.whoosh_color
	get_parent().add_child(arrow)

func _heal() -> void:
	inventory.remove_one(inventory.selected)
	#Radko, toto je na tebe

func _slam() -> void:
	_slam_center = global_position + Vector2.from_angle(_aim_angle()) * _held.slam_reach
	_rachnute.clear()
	_cakanka = _held.cas
	var ring := Whoosh.make(Whoosh.Kind.SHOCKWAVE, 0.0, _held.slam_radius, _held.whoosh_color)
	ring.start_extent = _held.slam_start_radius
	ring.duration = _held.cas
	_show_whoosh(ring, _slam_center)
	var query := PhysicsShapeQueryParameters2D.new()
	var supa := CircleShape2D.new()
	supa.radius = _held.slam_radius
	_rachnute.clear()
	query.shape = supa
	query.transform = Transform2D(0.0, _slam_center)
	query.exclude = [get_rid()]

	for result in get_world_2d().direct_space_state.intersect_shape(query):
		var body = result["collider"]
		if body is Entity and body != self and not _rachnute.has(body):
			_rachnute.append(body)
			body.damage(_held.damage)
			body.hod_stuck(_held.tlac,_held.otlac,Vector2.from_angle(_aim_angle()),_held.zasek)

func _start_spin() -> void:
	_t_cas = _held.cas
	_rachnute.clear()
	spin_cooldown = _held.spin_cooldown
	_speed_mult = _held.spin_speed_mult
	_brnko = _held.spin_damage_taken_mult
func _zastav_stav() -> void:
	_t_cas = 0.0
	_speed_mult = 1.0
	_brnko = 1.0
	$Sprite2D.rotation = 0.0
func _drop_item() -> void:
	var item := inventory.take_selected()
	if item == null:
		return
	Pickup.drop(get_parent(), (global_position + Vector2.from_angle(_aim_angle()) * 48.0), item, 1.0)


# ---------------------------------------------------------------- helpers
#generated by AI (Sonnet 5.5)
## Angle from the player to the mouse cursor.
func _aim_angle() -> float:
	return (get_global_mouse_position() - global_position).angle()

func _hit_shape(shape: Shape2D, xform: Transform2D, amount: int, already_hit: Array = []) -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = xform
	query.exclude = [get_rid()]
	# query.collision_mask = 0b10   # <- limit to your enemy layer(s) if needed
	for result in get_world_2d().direct_space_state.intersect_shape(query):
		var body = result["collider"]
		if body is Entity and body != self and not already_hit.has(body):
			already_hit.append(body)
			body.damage(amount)

## Saves the game when the window is closed.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()


## Where the save file lives: next to the exe in an exported game, in the project folder in the editor.
static func _save_path() -> String:
	var dir := ProjectSettings.globalize_path("res://") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()
	return dir.path_join("savegame.txt")


## The whole save file as a Dictionary, or null if there is none yet. The enemy spawner uses it too.
static func read_save() -> Variant:
	if not FileAccess.file_exists(_save_path()):
		return null
	var data: Variant = str_to_var(FileAccess.get_file_as_string(_save_path()))
	return data if data is Dictionary else null


## Writes position, inventory and all living enemies to the save file.
func save_game() -> void:
	var file := FileAccess.open(_save_path(), FileAccess.WRITE)
	if file == null:
		push_error("Could not write the save file")
		return
	var enemies := []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.health > 0:
			enemies.append(enemy.to_dict())
	file.store_string(var_to_str({
		"position": global_position,                 # remove if you rebuild the level on load
		"inventory": inventory.to_dict(),
		"enemies": enemies,
		"camps": campfires
		# add your Entity stats here, e.g. "health": health,
	}))


## Loads the save file, or gives the starting items if there is none yet.
func load_game() -> void:
	var data: Variant = read_save()
	if data == null:
		inventory.additem("mec")
		# inventory.additem("sek")
		inventory.additem("luk")
		#inventory.additem("dyka")
		#inventory.additem("kriak")
		# inventory.additem("palcat")
		return
	global_position = data.get("position", global_position)
	campfires = data.get("camps", [])

	var real_campfires = get_parent().get_node("Map").get_node("campfires")
	if real_campfires:
		var dist = INF
		var pos = Vector2.ZERO
		for camp in real_campfires.get_children():
			print(camp.get_path(), campfires)
			if camp.get_path() not in campfires:
				continue

			var new_dis = global_position.distance_to(camp.global_position)
			if dist > new_dis:
				dist= new_dis
				pos = camp.get_node("Spawn").global_position
		if pos != Vector2.ZERO:
			global_position = pos



	inventory.from_dict(data.get("inventory", {}))
	# restore your Entity stats here, e.g. health = data.get("health", health)

func _death():
	on_death.emit()

signal on_death()
