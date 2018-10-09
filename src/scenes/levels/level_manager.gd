extends Node2D

export (String) var level_name = "Training Grounds"
export (int) var current_wave = 0
export (int) var total_wave = 0
export (Array, int) var current_enemy_wave = []
export (Array, int) var enemy_wave_count = []

export (NodePath) onready var spawn_point = get_node(spawn_point)
export (NodePath) onready var player_spawn_point = get_node(player_spawn_point)
export (NodePath) onready var chest_spawn_point = get_node(chest_spawn_point)
export (NodePath) onready var gate_node = get_node(gate_node)
export (NodePath) onready var banner_node = get_node(banner_node)

export (Array, int) onready var armor_helm_pool
export (Array, int) onready var armor_chest_pool
export (Array, int) onready var armor_legs_pool
export (Array, int) onready var armor_weapon_pool
export (Array, int) onready var chest_reward

signal level_end
signal level_next
signal level_start

var ended = false

const Enemy = preload("res://scenes/units/enemy/Enemy.tscn")
const Chest = preload("res://scenes/interactable/lootable/chests/Chest.tscn")

func spawn():
	for i in range(0, enemy_wave_count[current_wave-1]):
		var unit = Enemy.instance()
		get_tree().get_nodes_in_group("Root_Units")[0].add_child(unit)
		var helm = armor_helm_pool[randi()%len(armor_helm_pool)]
		var chest = armor_chest_pool[randi()%len(armor_chest_pool)]
		var legs = armor_legs_pool[randi()%len(armor_legs_pool)]
		var weapon = armor_weapon_pool[randi()%len(armor_weapon_pool)]
		unit.equip_armor([helm, chest, legs])
		unit.equip_wep([weapon, 0])
		unit.position = spawn_point.position + Vector2(i - 100 + (i*10), i)
		current_enemy_wave.append(unit)

func _ready():
	utils.get_player().global_position = player_spawn_point.position
	utils.get_player().invunerable = false
	gate_node.disabled = true
	banner_node.disabled = false
	gate_node.connect("interact", self, "_on_gate_interact")
	banner_node.connect("interact", self, "_on_banner_interact")

func _process(d):
	if len(current_enemy_wave) > 0:
		var flag = true
		for unit in current_enemy_wave:
			flag = unit.dead
			if not flag:
				return
		if current_wave == total_wave:
			end_level()
		else:
			next_wave()	

func next_wave():
	current_wave+=1
	current_enemy_wave.clear()
	spawn()

func end_level():
	ended = true
	current_enemy_wave.clear()
	emit_signal("level_end")
	var chest = Chest.instance()
	get_tree().get_nodes_in_group("Root_Items")[0].add_child(chest)

	var timer = Timer.new()
	timer.set_wait_time(2)
	self.add_child(timer)
	timer.start()
	utils.get_player().stats.clear_effects()
	utils.get_player().invunerable = true
	yield(timer, "timeout")
	timer.queue_free()
	utils.get_player().global_position = player_spawn_point.position
	chest.global_position = chest_spawn_point.global_position
	chest.init(chest_reward)
	gate_node.disabled = false

func _on_gate_interact():
	emit_signal("level_next")
	gate_node.disabled = true

func _on_banner_interact():
	banner_node.disabled = true
	emit_signal("level_start")
	next_wave()
	