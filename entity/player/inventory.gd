class_name Inventory
extends Control
## The 4 item slots: holds the items AND draws them at the bottom of the screen.

const SLOTS := 4
const SLOT_SIZE := 64.0
const GAP := 8.0
const MARGIN := 16.0
var slot_texture: Texture2D = load("res://assets/ui/inv/inv.png")
var slot_texture_selected: Texture2D = load("res://assets/ui/inv/inv_selected.png")
var font: Font = load("res://assets/fonts/Silkscreen/Silkscreen-Regular.ttf")

var coins = 0
var items: Array[Item] = [null, null, null, null]   # one Item (a stack) per slot, null = empty
var selected := 0                                    # the slot currently in hand

## Fills the whole screen (the bar is drawn at the bottom) and lets mouse clicks pass through.
func _ready() -> void:
	
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## The item in the selected slot, or null if it is empty.
func selected_item() -> Item:
	return items[selected]


## Selects a slot. It wraps around, so -1 is the last slot.
func select(index: int) -> void:
	selected = wrapi(index, 0, SLOTS)
	queue_redraw()


## For stacks use "count", e.g. additem("herb", "count", 3). Returns how many did NOT fit.
func additem(type: String, n1 := "", v1: Variant = null, n2 := "", v2: Variant = null, n3 := "", v3: Variant = null, n4 := "", v4: Variant = null, n5 := "", v5: Variant = null, n6 := "", v6: Variant = null) -> int:
	var overrides := {}
	var names = [n1, n2, n3, n4, n5, n6]
	var values = [v1, v2, v3, v4, v5, v6]
	for i in names.size():
		if names[i] != "":
			overrides[names[i]] = values[i]
	return add(Item.new(type, overrides))


## Puts an item in the bar: first onto a matching stack, then into free slots. Returns how many did NOT fit.
func add(item: Item) -> int:
	if item.type == "coin":
		coins += item.count
		return 0
	if item.type == "prsten":
		var cam = get_viewport().get_camera_2d() as GameCamera
		if cam != null:
			cam.kolko_farebne += item.count
			if cam.kolko_farebne >=5:
				get_tree().change_scene_to_file("res://assets/ui/intro/outro.tscn")
			else:
				return 0
		else:
			print("nieco sa solidne pokazilo")

	var left = item.count
	for slot in items:
		if left > 0 and slot != null and slot.same_as(item) and slot.count < slot.max_stack:
			var moved = mini(left, slot.max_stack - slot.count)
			slot.count += moved
			left -= moved
	while left > 0:
		var free = items.find(null)
		if free == -1:
			break
		var moved = mini(left, maxi(item.max_stack, 1))
		items[free] = item.copy(moved)
		left -= moved
	queue_redraw()
	return left


## Uses up one item of a slot (a herb), or removes it completely (a weapon).
func remove_one(index: int) -> void:
	items[index].count -= 1
	if items[index].count <= 0:
		items[index] = null
	queue_redraw()


## Empties the selected slot and returns what was in it (null if it was empty). Used for dropping.
func take_selected() -> Item:
	var item := items[selected]
	items[selected] = null
	queue_redraw()
	return item


## Turns the inventory into plain data for the save file.
func to_dict() -> Dictionary:
	var saved := []
	for item in items:
		saved.append(item.to_dict() if item else {})
	return {"selected": selected, "items": saved, "coins": coins}


## Restores the inventory from saved data (see to_dict).
func from_dict(data: Dictionary) -> void:
	var saved: Array = data.get("items", [])
	for i in SLOTS:
		items[i] = null
		if i < saved.size() and Item.testy.has(saved[i].get("type", "")):
			items[i] = Item.from_dict(saved[i])
	selected = clampi(data.get("selected", 0), 0, SLOTS - 1)
	coins = data.get("coins", 0)
	queue_redraw()


## Draws the 4 slots at the bottom of the screen. The selected slot has a bright border.
func _draw() -> void:
	var total := SLOTS * SLOT_SIZE + (SLOTS - 1) * GAP
	var origin := Vector2((size.x - total) / 2.0, size.y - SLOT_SIZE - MARGIN)

	var style_box = StyleBoxTexture.new()
	style_box.texture = slot_texture
	style_box.set_texture_margin_all(18)

	var style_box_selected = StyleBoxTexture.new()
	style_box_selected.texture = slot_texture_selected
	style_box_selected.set_texture_margin_all(18)

	for i in SLOTS:
		var rect := Rect2(origin + Vector2(i * (SLOT_SIZE + GAP), 0.0), Vector2(SLOT_SIZE, SLOT_SIZE))
		var is_selected := i == selected

		# draw_rect(rect, Color(0, 0, 0, 0.55))
		# draw_rect(rect, Color.WHITE if is_selected else Color(1, 1, 1, 0.3), false, 3.0 if is_selected else 1.0)
		draw_style_box(style_box_selected if is_selected else style_box, rect)
		draw_string(font, rect.position + Vector2(10, 20), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.6))

		var item := items[i]
		if item == null:
			continue

		# the item's own color, with a text color that stays readable on it
		var text_color := Color.BLACK if item.color.get_luminance() > 0.5 else Color.WHITE
		# draw_rect(rect.grow(-10.0), item.color)
		if item.texture:
			var texture_size = item.texture.get_size()
			var size_factor = SLOT_SIZE / (max(texture_size.x , texture_size.y) + 12)
			texture_size *= size_factor * item.texture_scale

			var texture_position = rect.get_center() - (texture_size / 2)


			draw_texture_rect(item.texture, Rect2(texture_position, texture_size), false)
		else:
			draw_string(font, Vector2(rect.position.x, rect.position.y + SLOT_SIZE * 0.58), item.display_name, HORIZONTAL_ALIGNMENT_CENTER, SLOT_SIZE, 13, text_color)

		if item.max_stack > 1:
			draw_string(font, Vector2(rect.position.x, rect.end.y - 6.0), "x%d" % item.count, HORIZONTAL_ALIGNMENT_RIGHT, SLOT_SIZE - 6.0, 14, Color.WHITE)
