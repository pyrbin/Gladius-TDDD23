# Generic Observable container for item objects
# used in f.e player equipment, chests, unit equipments etc.
# TODO: Add support for multiple slots of same equippable type

extends Node

signal value_changed(slot)

const ItemData = preload("res://data/item_data.gd")
const Equippable = preload("res://data/equippable.gd")

var _item_container_array = []
var _item_type_array = []
var test = true
# container_slots - specify the container size + container types
# NOTE: should not use the same equip types multiple times (not supported)
func init(container_slots, start_equipped_items):
	var size = container_slots.size()
	_item_container_array.resize(size)
	_item_type_array.resize(size)
	for i in range(size):
		_item_container_array[i] = null
		_item_type_array[i] = container_slots[i]
	
	if not start_equipped_items: return

	for i in clamp(start_equipped_items.size(), 0, size):
		set(i, start_equipped_items[i])

func _in_bounds(slot):
	return slot <= _item_container_array.size() && slot >= 0

func _valid_id(item_id):
	return typeof(item_id) == TYPE_INT && item_id >= 0 && gb_ItemDatabase.has_item(item_id)

func _valid_item_in_slot(slot, item_id):
	return _item_type_array[slot] == 0 or item_id == null or gb_ItemDatabase.get_item(item_id).slot == _item_type_array[slot]

func set(slot, item_id):
	var success = false
	if slot == null: 
		return success
	if not _in_bounds(slot):
		return success
	if not _valid_id(item_id):
		delete(slot)
		success = true
	elif _valid_item_in_slot(slot, item_id):
		_item_container_array[slot] = item_id
		success = true
	emit_signal("value_changed", slot)
	return success

func append(item_id):
	return set(get_empty_slot(), item_id)

func delete(slot):
	if not _in_bounds(slot): return
	_item_container_array[slot] = null
	emit_signal("value_changed", slot)

func get_empty_slot ():
	for i in range(0, _item_container_array.size()):
		if _item_container_array[i] == null:
			return i
	return null

func get_equip_slot(slot_type):
	if slot_type == 0:
		return get_empty_slot()
	return _item_type_array.find(slot_type)

func move_item(from, to):
	var success = false
	var tmp_t = _item_container_array[to]
	var tmp_f = _item_container_array[from]
	if _valid_item_in_slot(from, tmp_t) and _valid_item_in_slot(to, tmp_f):
		_item_container_array[to] = tmp_f
		_item_container_array[from] = tmp_t
		success = true
	if _in_bounds(from):
		emit_signal("value_changed", from)
	if _in_bounds(to):
		emit_signal("value_changed", to)
	return success

func has(item_id):
	return _item_container_array.has(item_id)

func get(slot):
	return _item_container_array[int(slot)]

func get_type(slot):
	return _item_type_array[slot]

func get_list():
	return gb_Utils.deep_copy(_item_container_array)

func size():
	return _item_container_array.size()