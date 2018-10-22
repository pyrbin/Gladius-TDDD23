extends Node2D

func switching():
	var armor_sets = [
		[0, 2000, 3000],
		[1000, 2000, 3100],
		[1000, 2100, 3100],
		[1200, 2100, 3100],
		[1200, 2100, 3200],
		[1200, 2300, 3200],
		[1300, 2300, 3200],
		[1300, 2300, 3300],
		[1100, 2300, 3300],
	]

	for set in armor_sets:
		utils.get_player().equip_armor(set)
		yield(utils.timer(0.5), "timeout")

func _unhandled_input(e):
	if e.is_action_pressed("ui_accept"):
		switching()