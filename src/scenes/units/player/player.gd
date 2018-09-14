extends "res://scenes/units/unit.gd"

signal item_in_range
signal pickup_item

var items_to_pickup = []

var inventory_controller
var equipment_controller

var toggle = true
func _ready():
    #inventory_controller = get_tree().get_root().get_node("/root/Game/GUI/PlayerInventory")
    equipment_controller = get_tree().get_root().get_node("/root/Game/GUI/PlayerEquipment")

    #inventory_controller.connect_to_item_container(inventory)
    equipment_controller.connect_to_item_container(equipment, self)

    #inventory_controller.connect_controller(equipment_controller)
    #equipment_controller.connect_controller(inventory_controller)

func _unhandled_input(event):
    $StateMachine.handle_input(event)
    if (Input.is_key_pressed(KEY_ESCAPE)):
        if toggle: 
            toggle = not toggle
            equipment_controller.hide()
        else:
            toggle = not toggle
            equipment_controller.show()

func _physics_process(delta):

    if (Input.is_action_pressed("left_attack")):
        var events = InputMap.get_action_list("left_attack")
        for e in events:
            e.pressed = true
            $StateMachine.handle_input(e)

    if (Input.is_action_pressed("sprint")):
        var events = InputMap.get_action_list("sprint")
        for e in events:
            e.pressed = true
            $StateMachine.handle_input(e)
        
func get_movement_direction():
    var direction = Vector2()
    direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
    direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
    return direction

func get_aim_position():
    return get_global_mouse_position()

func _on_collision(body):
    pass

func set_for_pickup(node, status):
    if status:
        items_to_pickup.append(node)
        emit_signal("item_in_range")
    else:
        node.set_shader_color()
        var idx = items_to_pickup.find(node)
        if idx != -1:
            items_to_pickup.remove(idx)

func pickup_item():
    emit_signal("pickup_item")
