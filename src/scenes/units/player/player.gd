extends "res://scenes/units/unit.gd"

var inventory_controller
var toggle = true
func _ready():
	inventory_controller = get_tree().get_root().get_node("/root/Game/GUI/PlayerInventory")
	inventory_controller.connect_to_inventory(inventory)

func _input(event):
	$StateMachine.handle_input(event)
	if (Input.is_key_pressed(KEY_ESCAPE)):
		if toggle: 
			inventory_controller.hide()
			toggle = not toggle
		else:
			inventory_controller.show()
			toggle = not toggle

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
