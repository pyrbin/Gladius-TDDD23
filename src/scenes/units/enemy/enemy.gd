extends "res://scenes/units/unit.gd"

var event_move_down = null

func _ready():
	event_move_down = InputMap.get_action_list("move_down")

func get_movement_direction():
	#return (get_node("/root/Root/Player").position - position).normalized()
	return Vector2()

func get_aim_position():
	return Vector2()

func _process(delta):
#	for e in event_move_down:
#		e.pressed = true
#		$StateMachine.handle_input(e)
	pass