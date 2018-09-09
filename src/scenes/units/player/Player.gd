extends "res://scenes/units/Unit.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var lmb_down= false
var rmb_down = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	$StateMachine.handle_input(event)

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
