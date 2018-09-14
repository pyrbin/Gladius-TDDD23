extends Control

export (Color) var pickup_color = Color(0,1,0)

onready var item_pickup_label = $Item_Pickup_Label
const PICKUP_RESET_VALUE = 999999

var player = null
var pickup_enabled = false
# Item world object (not data object)
var item_to_pickup = null
# Current lowest distance to character
var min_dist = PICKUP_RESET_VALUE

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	player.connect("item_in_range", self, "_item_in_range")
	player.connect("pickup_item", self, "_pickup_item")

func _item_in_range():
	_set_pickup(true)

func _process(delta):

	if player.items_to_pickup.size() == 0:
		_set_pickup(false)
		return

	var string = ""
	var player_pos = Vector2(player.global_position.x, player.global_position.y+12)
	for item in player.items_to_pickup:
		var dist = item.global_position.distance_to(player_pos)
		if item.item_id == null: continue
		if (dist < min_dist && item != item_to_pickup):
			min_dist = dist
			if (item_to_pickup):
				item_to_pickup.set_shader_color()
			item_to_pickup = item

	if item_to_pickup != null:
		string = "Press [color=red][b]( E )[/b][/color] to pickup: [code][color=blue][b]" + item_to_pickup.item_data.name + "[/b][/color][/code] \n"
		item_to_pickup.set_shader_color(pickup_color)

	item_pickup_label.set_bbcode(string)

func _set_pickup(b):
	pickup_enabled = b
	min_dist = PICKUP_RESET_VALUE
	if (item_to_pickup):
		item_to_pickup.set_shader_color()
	item_to_pickup = null
	item_pickup_label.set_bbcode("")
	set_process(pickup_enabled)

func _pickup_item():
	if not item_to_pickup:
		return
	var item = gb_ItemDatabase.get_item(item_to_pickup.item_id)
	var slot = player.equipment.get_equip_slot(item.slot)
	min_dist = PICKUP_RESET_VALUE
	player.set_for_pickup(item_to_pickup, false)
	player.equipment_controller.drop_item(slot)
	player.equipment.set(slot, item_to_pickup.item_id)
	item_to_pickup.visible = false
	item_to_pickup.set_shader_color()
	var to_delete = item_to_pickup
	item_to_pickup = null
	to_delete.queue_free()
