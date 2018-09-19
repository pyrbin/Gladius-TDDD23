extends "res://scenes/units/unit.gd"

var event_move_down = null

func _ready():
	event_move_down = InputMap.get_action_list("left_attack")

func get_movement_direction():
	#return (get_node("/root/Root/Player").position - position).normalized()
	return Vector2()

func get_aim_position():
	return get_tree().get_nodes_in_group("Player")[0].global_position

func _process(delta):
	for e in event_move_down:
		e.pressed = true
		$StateMachine.handle_input(e)
	pass