extends Node2D

export (String) var level_name = "Training Grounds"
export (int) var current_wave = 0
export (int) var total_wave = 0
export (bool) var hide_labels = true

export (Array, int) var current_enemy_wave = []
export (Array, int) var enemy_wave_count = []

export (NodePath) onready var spawn_point = get_node(spawn_point)
export (NodePath) onready var spawn_point_two = get_node(spawn_point_two)
export (NodePath) onready var spawn_point_three = get_node(spawn_point_three)

export (NodePath) onready var player_spawn_point = get_node(player_spawn_point)
export (NodePath) onready var chest_spawn_point = get_node(chest_spawn_point)
export (NodePath) onready var gate_node = get_node(gate_node)  
export (NodePath) onready var banner_node = get_node(banner_node)
export (Array) var sfx_cheers
export (AudioStream) var sfx_spawn
export (AudioStream) var sfx_audience
export (AudioStream) var sfx_big_cheers

export (int, "Easy", "Advanced", "Master") onready var max_ai_difficulty = 0

export (Array, int) onready var armor_helm_pool
export (Array, int) onready var armor_chest_pool
export (Array, int) onready var armor_legs_pool
export (Array, int) onready var armor_weapon_pool
export (Array, int) onready var chest_reward_helm
export (Array, int) onready var chest_reward_legs
export (Array, int) onready var chest_reward_chest
export (Array, int) onready var chest_reward_weapon
export (Array, int) onready var chest_reward_potion


signal level_end
signal level_next
signal level_start

var ended = false

const Enemy = preload("res://scenes/units/enemy/Enemy.tscn")
const Chest = preload("res://scenes/interactable/lootable/chests/Chest.tscn")

var spawning = false

func spawn():
    spawning = true
    spawn_random()
    spawning = false

func spawn_random():
    for i in range(0, enemy_wave_count[current_wave-1]):
        var unit = Enemy.instance()
        utils.singleton("Root_Units").add_child(unit)
        var helm = armor_helm_pool[randi()%len(armor_helm_pool)]
        var chest = armor_chest_pool[randi()%len(armor_chest_pool)]
        var legs = armor_legs_pool[randi()%len(armor_legs_pool)]
        var weapon = armor_weapon_pool[randi()%len(armor_weapon_pool)]
        unit.equip_armor([helm, chest, legs])
        unit.equip_wep([weapon, 0])
        var s_pos = null
        if current_wave % 2 == 0:
            s_pos = spawn_point_two
        elif current_wave % 3 == 0:
            s_pos = spawn_point_three
        else:
            s_pos = spawn_point
        if max_ai_difficulty > 0:
            if randi()%2 == 2:
                unit.set_ai_difficulty(max_ai_difficulty)
        unit.position = s_pos.position + Vector2(i - 100 + (i*10), i)
        current_enemy_wave.append(unit)
        unit.connect("dead", self, "_on_unit_killed")
        yield(utils.timer(1.5), "timeout")

func _on_unit_killed(val):
    var flag = true
    for unit in current_enemy_wave:
        flag = unit.dead
        if not flag:
            break
    if not flag:
        var cheer = sfx_cheers[randi()%len(sfx_cheers)]
        if not $CheersPlayer.playing:
            utils.play_sound(cheer, $CheersPlayer)
    else:
        utils.play_sound(sfx_big_cheers, $CheersPlayer)

func _ready():
    utils.get_player().global_position = player_spawn_point.position
    utils.get_player().invunerable = false
    utils.get_player().equip_armor(game.player_equipment)
    utils.get_player().equip_wep(game.player_weapons)
    gate_node.disabled = true
    banner_node.disabled = false
    gate_node.connect("interact", self, "_on_gate_interact")
    banner_node.connect("interact", self, "_on_banner_interact")
    utils.play_sound(sfx_audience, $SpecPlayer)

func _process(d):
    if len(current_enemy_wave) > 0:
        var flag = true
        for unit in current_enemy_wave:
            flag = unit.dead
            if not flag:
                return
        if current_wave >= total_wave:
            end_level()
        elif current_wave < total_wave:
            next_wave()	

func next_wave():
    current_enemy_wave.clear()
    yield(utils.timer(2), "timeout")
    utils.play_sound(sfx_spawn, $AudioPlayer)
    current_wave+=1
    spawn()

func end_level():
    if not hide_labels:
        $Labels/ChestLabel.show()
        $Labels/GateLabel.show()
    
    ended = true
    current_enemy_wave.clear()
    emit_signal("level_end")
    var chest = Chest.instance()
    utils.singleton("Root_Items").add_child(chest)
    utils.get_player().stats.clear_effects()
    utils.get_player().invunerable = true
    utils.get_player().damage(-utils.get_player().status.get_max_health(), utils.get_player())
    yield(utils.timer(2), "timeout")
    utils.get_player().global_position = player_spawn_point.position
    chest.global_position = chest_spawn_point.global_position

    var reward_list = []

    for rewards in [chest_reward_chest, chest_reward_helm, chest_reward_legs, chest_reward_potion, chest_reward_weapon]:
        var item = rewards[randi()%len(rewards)]
        reward_list.append(item)

    chest.init(reward_list)
    gate_node.disabled = false
    
func _on_gate_interact():
    game.player_equipment = utils.get_player().equipment.get_list()
    game.player_weapons = utils.get_player().action_equipment.get_list()
    emit_signal("level_next")
    gate_node.disabled = true


func _on_banner_interact():
    $Labels/BannerLabel.hide()
    banner_node.disabled = true
    var main_audio = utils.singleton("MainAudio")
    main_audio.fade_out(game.theme_main)
    emit_signal("level_start")
    next_wave()
    