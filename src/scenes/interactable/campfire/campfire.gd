extends "../interactable.gd"

export(bool) var flame_on = false
onready var particles = $Visuals/Pivot/Particles2D
onready var light = $Visuals/Pivot/Light2D

func _ready():
	light()

func get_action_string():
	return make_action_string("Start") + " [color=orange]" + "Level" + "[/color] \n"

func light():
	if not flame_on:
		anim_player.play("active")
	else:
		anim_player.stop()
	flame_on = not flame_on
	# particles.emitting = flame_on
	# light.enabled = flame_on

func interact():
	light()
	return .interact()
