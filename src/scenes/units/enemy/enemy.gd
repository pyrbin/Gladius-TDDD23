extends "res://scenes/units/unit.gd"

export (bool) var disable_AI = false
export (int, "Easy", "Advanced", "Master") var ai_difficulty = 0

enum AI_STATE {
    SEEK
    COMBAT
    THINKING
}

const EASY_WAIT_BASH = 10
const ADV_WAIT_BASH = 7
const MAS_WAIT_BASH = 3

const EASY_WAIT_JUMP = 12
const ADV_WAIT_JUMP = 7
const MAS_WAIT_JUMP = 5

var nav = null
var path = null
var mov_dir = Vector2()
var last_player_pos = Vector2()
var ai_state = AI_STATE.SEEK
var can_bash = true
var can_jump = true
var last_dir = Vector2()

func _setup():
    if not disable_AI:
        nav = get_tree().get_nodes_in_group("Navigation")[0]
    get_player().connect("attacking", self, "_on_player_attack")
    randomize()

    if randi()%1 == 0:
        can_jump = false
        $AIBehaviour/CanJump.start()
        can_bash= false
        $AIBehaviour/CanBash.start()
    set_ai_difficulty(ai_difficulty)

func set_ai_difficulty(id):
    ai_difficulty = id
    if ai_difficulty == 0:
        $AIBehaviour/CanBash.wait_time = EASY_WAIT_BASH
        $AIBehaviour/CanJump.wait_time = EASY_WAIT_JUMP
    if ai_difficulty == 1:
        $AIBehaviour/CanBash.wait_time = ADV_WAIT_BASH
        $AIBehaviour/CanJump.wait_time = ADV_WAIT_JUMP
    if ai_difficulty == 2:
        $AIBehaviour/CanBash.wait_time = MAS_WAIT_BASH
        $AIBehaviour/CanJump.wait_time = MAS_WAIT_JUMP

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

func logic_thinking():
    if $AIBehaviour/Thinking.is_stopped():
        $AIBehaviour/Thinking.start()

func _on_Thinking_timeout():
    ai_state = SEEK

func logic_seek():
    if can_jump && player_aim_near_me() && player_used_weapon():
        _send_action("jump")
        can_jump = false
        $AIBehaviour/CanJump.start()
    if weapon_in_range():
        ai_state = AI_STATE.COMBAT

func logic_combat():
    if get_weapon_node().is_ready():
        _send_action("attack")
        last_dir = get_aim_position()
        ai_state = THINKING
        yield(utils.timer(1.65), "timeout")
        ai_state = SEEK
    if not weapon_in_range():
        yield(utils.timer(0.4), "timeout")
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
    if can_bash && is_in_bash(get_player()) && ai_state != THINKING:
        _send_action("block")
        can_bash = false
        $AIBehaviour/CanBash.start()

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
    
func _on_CanBash_timeout():
    can_bash = true

func _on_CanJump_timeout():
    can_jump = true

func set_dead(value):
    disable_AI = value;
    return .set_dead(value)