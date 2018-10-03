extends "res://scenes/units/unit.gd"

signal on_interactable_join
signal on_interact
signal player_loaded

onready var camera = $CameraPivot/Camera2D
var interactable_list = []

var toggle_CP = true
var toggle_GUI = false
var pressed = false
var locked = false

func _setup():
    emit_signal("player_loaded")

func _input(event):
    if locked: return
    if event.is_action_pressed("ui_character_panel"):
        var menu = get_tree().get_nodes_in_group("Character_Panel")[0]
        menu.show() if toggle_CP else menu.hide()
        toggle_CP = not toggle_CP
    if event.is_action_pressed("ui_hide"):
        var GUI = get_tree().get_nodes_in_group("GUI")[0].get_node("Interface")
        GUI.show() if toggle_GUI else GUI.hide()
        toggle_GUI = not toggle_GUI
    $StateMachine.handle_input(event)

func _process(delta):
    $Visuals/Selection.look_at(get_aim_position())
    """if (Input.is_action_pressed("attack")):
        var events = InputMap.get_action_list("attack")
        for e in events:
            e.pressed = true
            $StateMachine.handle_input(e)
    """
    pass
        
func get_movement_direction():
    if locked: return
    var direction = Vector2()
    direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
    direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
    return direction

func get_aim_position():
    return get_global_mouse_position()

func _on_collision(body):
    pass

    
func queue_interactable(interactable, status):
    if status:
        interactable_list.append(interactable)
        emit_signal("on_interactable_join")
    else:
        interactable.set_shader_color()
        var idx = interactable_list.find(interactable)
        if idx != -1:
            interactable_list.remove(idx)

func on_interact():
    emit_signal("on_interact")
    
func _on_Player_took_damage(amount, actor, soft):
    if amount > 0:
        camera.shake(0.35, 20, 3.5)

