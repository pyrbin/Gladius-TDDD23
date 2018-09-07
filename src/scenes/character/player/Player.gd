extends "res://scenes/character/Character.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _input(event):
	var move_up = event.is_action_pressed("move_up")
	var move_down = event.is_action_pressed("move_down")
	var move_left = event.is_action_pressed("move_left")
	var move_right = event.is_action_pressed("move_right")
	
	var new_vel = Vector2(0,0)
	
	if move_up:
		new_vel += Vector2(0,-1)
	elif move_down:
		new_vel += Vector2(0,1)
	if move_left:
		new_vel += Vector2(-1,0)
	elif move_right:
		new_vel += Vector2(1,0)
	
	velocity = new_vel * speed
	
	

func _physics_process(delta):
	pass