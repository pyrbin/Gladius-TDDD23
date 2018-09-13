# Inventory

extends Node

signal value_changed

export (int) var inventory_size = 0

const ItemData = preload("item_data.gd")
const Equippable = preload("equippable.gd")

const INVENTORY_MAX_SIZE = 6

var _inventory_array = []
var _equipment_dict  = {}

func _ready():
	var size = clamp(inventory_size, 1, INVENTORY_MAX_SIZE)
	_inventory_array.resize(size)
	for i in range(size):
		_inventory_array[i] = null
		
	_equipment_dict = {
		Equippable.SLOT.HELM : null,
		Equippable.SLOT.CHEST : null,
		Equippable.SLOT.LEGS : null,
		Equippable.SLOT.WEAPON : null,
		Equippable.SLOT.SPECIAL : null
	}

func equip(slot, item):
	if item.type != ItemData.ITEM_TYPE.EQUIPPABLE:
		return
	_equipment_dict[slot] = item

func _in_bounds(slot):
	return slot <= _inventory_array.size()

func _valid_id(item_id):
	return typeof(item_id) == TYPE_INT && ItemDatabase.has_item(item_id)

func set (slot, item_id):
	if slot == null: 
		return
	if not _in_bounds(slot):
		return false
	if not _valid_id(item_id):
		delete(slot)
	_inventory_array[slot] = item_id
	emit_signal("value_changed", slot)

func append(item_id):
	set(get_empty_slot(), item_id)

func delete(slot):
	_inventory_array[slot] = null
	emit_signal("value_changed", slot)

func get_empty_slot ():
	for i in range(0, _inventory_array.size()):
		if _inventory_array[i] == null:
			return i
	return -1

func move_item(from, to):
	var tmp = _inventory_array[to]
	_inventory_array[to] = _inventory_array[from]
	_inventory_array[from] = tmp
	emit_signal("value_changed", from)
	emit_signal("value_changed", to)

func has(item_id):
	return _inventory_array.has(item_id)

func get(slot):
	return _inventory_array[slot]

func size():
	return _inventory_array.size()