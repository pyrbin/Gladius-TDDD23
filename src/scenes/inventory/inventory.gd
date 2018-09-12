# Inventory

extends Node

signal value_changed

export (int) var inventory_size = 0

const ItemData = preload("item_data.gd")
const Equippable = preload("equippable.gd")

const INVENTORY_MAX_SIZE = 6

var _inventory_array = []
var _equipment_dict  = {}

var _size = 0

func _ready():
	_size = clamp(inventory_size, 1, INVENTORY_MAX_SIZE)
	_inventory_array.resize(_size)
	for i in range(_size):
		_inventory_array[i] = null
		
	_equipment_dict = {
		Equippable.SLOT.HELM : null,
		Equippable.SLOT.CHEST : null,
		Equippable.SLOT.LEGS : null,
		Equippable.SLOT.WEAPON : null,
		Equippable.SLOT.SPECIAL : null
	}

func _in_bounds(slot):
	return slot <= _size

func _valid_id(item_id):
	return typeof(item_id) == TYPE_INT && ItemDatabase.has_item(item_id)

func set (slot, item_id):
	if (not _in_bounds(slot) or not _valid_id(item_id)):
		return false
	_inventory_array[slot] = item_id
	emit_signal("value_changed", slot)

func delete(slot):
	_inventory_array[slot] = null
	emit_signal("value_changed", slot)

func set_if_empty (slot, item_id):
	if (not _in_bounds(slot) or not _valid_id(item_id)):
		return false
	if _inventory_array[slot] != null:
		return false
	_inventory_array[slot] = item_id
	emit_signal("value_changed", slot)

func has(item_id):
	return _inventory_array.has(item_id)

func get(slot):
	return _inventory_array[slot]

func size():
	return _inventory_array.size()