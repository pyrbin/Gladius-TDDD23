extends "res://scenes/units/unit.gd"

export (bool) var disable_AI = false

var nav = null
var path
var player_pos
var mov_dir = Vector2()

func _setup():
    if disable_AI:
        nav = get_tree().get_nodes_in_group("Navigation")[0]
    get_player().connect("attacking", self, "_on_player_attack")

func _send_action(action):
    var event = InputMap.get_action_list(action)
    for e in event:
        e.pressed = true
        $StateMachine.handle_input(e)

func get_movement_direction():
    if disable_AI: return Vector2()
    if player_in_range() && weapon_in_range() || not nav: return mov_dir
    var dir = Vector2()
    if player_pos != get_player().global_position:
        player_pos = get_player().global_position
        path = nav.get_simple_path(global_position, player_pos)
        path.remove(0)
    if to_move():
        dir = (to_move() - global_position).normalized()
    return dir

func to_move():
    return path[0] if path else Vector2()

func get_aim_position():
    return get_player().global_position# + Vector2(0, -24)

func set_dead(b):
    $Visuals/AimIndicator.show() if not b else $Visuals/AimIndicator.hide()
    return .set_dead(b)

func get_player():
    return get_tree().get_nodes_in_group("Player")[0]

func get_range():
    return get_weapon_node().hit_range if get_weapon_node() else -99999

func _logic_player_in_range():
    if weapon_in_range():
        _send_action("attack")
    
    if get_weapon_node().data.weapon_type == 2:
        _logic_keep_distance()

func _on_player_attack():
    #_send_action("block")
    return
    
func _logic_keep_distance():
    if global_position.distance_to(get_player().global_position) < 150 && weapon_in_range() && gb_Utils.rng_chance(50):
        var mod = 1 if randi()%1 else -1
        mov_dir = mod*(get_player().global_position - global_position).normalized()
        _send_action("jump")
        mov_dir = Vector2()


func player_in_range():
    return global_position.distance_to(get_player().global_position) < get_range()

func weapon_in_range():
    return get_weapon_node().see_target(get_player())

func _process(delta):
    if disable_AI: return

    if player_in_range():
        _logic_player_in_range()

    if path && position.distance_to(to_move()) <= 10:
        path.remove(0)