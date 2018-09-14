extends "../interactable.gd"

const Equippable = preload("res://data/equippable.gd")
const UNKNOWN_ICON_PATH = "res://assets/items/unknown_icon.png"
export (int) var item_id
onready var item_data = null

func _ready():
	set_item(item_id)
	
func get_action_string():
	if item_data == null: return
	return "pickup: [code][color=blue][b]" + item_data.name + "[/b][/color][/code] \n"


func set_item(item_id):
	var item = gb_ItemDatabase.get_item(item_id)
	if item == null:
		interactable = false
		set_visible(false)
		return
	self.item_id = item_id
	item_data = item
	set_visible(true)
	interactable = true
	if (sprite && anim_player):
		if item_data.slot == Equippable.SLOT.WEAPON:
			sprite.rotation = 100
		else:
			sprite.rotation = 0
		var icon = load(item_data.icon)
		sprite.set_texture(icon if icon != null else load(UNKNOWN_ICON_PATH))
		set_shader_color()

func interact():
	var item = gb_ItemDatabase.get_item(item_id)
	var slot = player.equipment.get_equip_slot(item.slot)
	player.queue_interactable(self, false)
	player.equipment_controller.drop_item(slot)
	player.equipment.set(slot, item_id)
	visible = false
	set_shader_color()
	queue_free()