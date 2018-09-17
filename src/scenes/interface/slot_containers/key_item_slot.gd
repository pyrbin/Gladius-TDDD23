extends "res://scenes/interface/slot_containers/item_slot.gd"

var key = "" setget set_key

func set_key(p_key):
	key = p_key
	$Key.set_text(p_key)
	if p_key == null || p_key == "":
		$Key.hide()
	else:
		$Key.show()

