extends "res://scenes/units/Unit.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _physics_process(delta):

	var direction = Vector2()
	var tmp_speed = speed

	var move_up = Input.is_action_pressed("move_up")
	var move_down = Input.is_action_pressed("move_down")
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	
	if move_up:
		direction.y += -1
	if move_down:
		direction.y += 1
	if move_left:
		direction.x += -1
	if move_right:
		direction.x += 1

	if direction.length() > 1:
		# Reduce diagonal movementspeed
		tmp_speed /= sqrt(2)
		
	velocity = direction * tmp_speed