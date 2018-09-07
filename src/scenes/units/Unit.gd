extends KinematicBody2D

export (int) var health = 200
export (int) var speed = 200

var look_vec = Vector2(0,0)
var velocity = Vector2(0,0)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _aim_at(look_vec):
	pass

func _physics_process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	_aim_at(look_vec)
	move_and_slide(velocity)
	
