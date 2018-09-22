extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _process(d):
	look_at(owner.get_aim_position())