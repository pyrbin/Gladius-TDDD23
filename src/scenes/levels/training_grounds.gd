extends "res://scenes/levels/level_manager.gd"

func spawn():
	for i in range(0, enemy_wave_count[current_wave-1]):
		var unit = Enemy.instance()
		get_tree().get_nodes_in_group("Root_Units")[0].add_child(unit)
		var helm = armor_helm_pool[randi()%len(armor_helm_pool)]
		var chest = armor_chest_pool[randi()%len(armor_chest_pool)]
		var legs = armor_legs_pool[randi()%len(armor_legs_pool)]
		var weapon = armor_weapon_pool[randi()%len(armor_weapon_pool)]
		unit.equip_armor([helm, chest, legs])
		unit.equip_wep(get_weapon_by_level())
		unit.position = spawn_point.position + Vector2(i - 100 + (i*10), i)
		current_enemy_wave.append(unit)
		yield(utils.timer(0.5), "timeout")

func get_weapon_by_level():
	var weapon = 4001
	# SWORD
	if current_wave >= 1 && current_wave <= 3:
		weapon = 4001
	# DAGGER
	if current_wave >= 4 && current_wave <= 6:
		weapon = 4003
	# SPEAR
	if current_wave >= 7 && current_wave <= 9:
		weapon = 4002
	# HAMMER
	if current_wave >= 10 && current_wave <= 12:
		weapon = 4001
	# RANGED
	if current_wave >= 13 && current_wave <= 15:
		weapon = 4004
	return [weapon, 0]

func _on_GateEnter_interact():
	utils.get_player().global_position = $Arena_Spawn.global_position
	player_spawn_point.global_position = $Player_Spawn_End.global_position