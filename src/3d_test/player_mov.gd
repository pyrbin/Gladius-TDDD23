extends KinematicBody

var linear_velocity = Vector3()

func _ready():
    # Called when the node is added to the scene for the first time.
    # Initialization here
    pass

func _process(delta):
    linear_velocity = Vector3()
    if Input.is_action_pressed("move_right"):
        linear_velocity += Vector3(1, 0, 0)
    if Input.is_action_pressed("move_up"):
        linear_velocity += Vector3(0, 0, -1)
    if Input.is_action_pressed("move_left"):
        linear_velocity += Vector3(-1, 0, 0)
    if Input.is_action_pressed("move_down"):
        linear_velocity += Vector3(0, 0, 1)
    move_and_collide(linear_velocity*delta*3)