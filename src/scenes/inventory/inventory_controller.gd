extends Control

const Inventory = preload("inventory.gd")

const MAX_SIZE = 6

onready var inventory_list = $Panel/Inventory
onready var equipment_list = $Panel/Inventory

var inventory = null
var owner_of_inventory = null

func _ready():
    inventory_list.set_max_columns(MAX_SIZE)
    inventory_list.set_fixed_icon_size(Vector2(96,96))
    inventory_list.set_icon_mode(ItemList.ICON_MODE_TOP)
    inventory_list.set_select_mode(ItemList.SELECT_SINGLE)
    inventory_list.set_same_column_width(true)
    inventory_list.set_allow_rmb_select(true)
    #inventory_list.set_size(Vector2(96*MAX_SIZE, 107))

func connect_to_inventory(p_inventory):
    if inventory:
        inventory.clear()
        inventory.disconnect("value_changed", self, "_on_inventory_changed")
    inventory = p_inventory
    if p_inventory == null:
        return
    _load_items()
    inventory.connect("value_changed", self, "_on_inventory_changed")

func _on_inventory_changed(slot):
    _update_item_slot(slot)

func _update_item_slot(slot):
    var item_id = inventory.get(slot)
    if item_id == null: 
        _set_empty(slot)
        return
    var item = ItemDatabase.get_item(item_id)
    if item == null:
        _set_empty(slot)
        return
    inventory_list.set_item_icon(slot, load(item.icon))
    inventory_list.set_item_metadata(slot, item)
    inventory_list.set_item_tooltip(slot, item.name)
    inventory_list.set_item_selectable(slot, true)
    inventory_list.set_item_tooltip_enabled(slot, true)

func _set_empty(slot):
    inventory_list.set_item_icon(slot, null)
    inventory_list.set_item_selectable(slot, false)
    inventory_list.set_item_metadata(slot, null)
    inventory_list.set_item_tooltip(slot, "")
    inventory_list.set_item_tooltip_enabled(slot, false)

func _load_items():
    inventory_list.clear()
    for slot in range(0, inventory.size()):
        inventory_list.add_item("", null, true)
        _update_item_slot(slot)

func _on_Button_pressed():
    inventory.set(randi()%6, 0)

func _on_Button2_pressed():
    inventory.delete(randi()%6)