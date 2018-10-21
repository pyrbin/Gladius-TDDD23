extends "res://scenes/units/unit.gd"

export (String) var boss_name = "Boss123"
export (bool) var disable_AI = false
export (PackedScene) var pitfall = null

enum AI_STATE {
    SEEK
    COMBAT
    THINKING
}

var nav = null
var path = null
var mov_dir = Vector2()
var last_player_pos = Vector2()
var ai_state = AI_STATE.SEEK
var last_dir = Vector2()

var berserk = false

func _setup():
    if not disable_AI:
        nav = get_tree().get_nodes_in_group("Navigation")[0]
    get_player().connect("attacking", self, "_on_player_attack")

func _process(delta):
    if disable_AI: return
    if get_player().dead:
        disable_AI = true
    match ai_state:
        SEEK:     logic_seek()
        COMBAT:   logic_combat()
        THINKING: logic_thinking()
    if path && position.distance_to(to_move()) <= 10:
        path.remove(0)
    boss_phases()

func boss_phases():
    if status.get_health_perc() <= 0.33 && not berserk:
        berserk = true
        stats.add_effect_fac("BERSERKZ", STAT.ATK_SPEED, 300, STAT.VALUE)


func logic_thinking():
    if $AIBehaviour/Thinking.is_stopped():
        $AIBehaviour/Thinking.start()

func _on_Thinking_timeout():
    ai_state = SEEK

func logic_seek():
    if weapon_in_range():
        ai_state = AI_STATE.COMBAT

func logic_combat():
    if get_weapon_node().is_ready():
        _send_action("attack")
        last_dir = get_aim_position()
        ai_state = THINKING

    if not weapon_in_range():
        yield(utils.timer(0.5), "timeout")
        ai_state = AI_STATE.SEEK

func get_movement_direction():
    if disable_AI: 
        return Vector2()
    if not nav: 
        return Vector2()
    if ai_state != AI_STATE.SEEK:
        return Vector2()
    if last_player_pos != get_player().global_position:
        last_player_pos = get_player().global_position
        path = nav.get_simple_path(global_position, last_player_pos)
        path.remove(0)
    if to_move():
        mov_dir = utils.dir_from(global_position, to_move())
    return mov_dir

    
func _on_player_attack():
	pass

func player_aim_near_me():
    return get_player().get_aim_position().distance_to(global_position) <= 50

func player_used_weapon():
    return get_player().weapon && not get_player().weapon.is_ready() && not get_player().weapon.is_holstered()

func player_in_range():
    return global_position.distance_to(get_player().global_position) < get_range()

func weapon_in_range():
    return get_weapon_node().see_target(get_player())

func get_aim_position():
    return get_player().global_position + Vector2(0, -5)

func to_move():
    return path[0] if path else Vector2()

func get_player():
    return utils.get_player()

func get_range():
    return get_weapon_node().hit_range if get_weapon_node() else -99999

func _send_action(action):
    var event = InputMap.get_action_list(action)
    for e in event:
        e.pressed = true
        $StateMachine.handle_input(e)
    
func set_dead(value):
    disable_AI = value;
    return .set_dead(value)

func _on_Pitfalls_timeout():
    var p = pitfall.instance()
    utils.singleton("Root_Items").add_child(p)
    p.global_position = utils.get_player().global_position
