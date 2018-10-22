extends Control

func _ready():
    $Start.hide()
    $Label.connect("is_done", self, "_on_text_done");
    yield(utils.timer(1), "timeout")
    $Label.start = true
func _input(event):
	if event.is_action_pressed("ui_select") && $Start.is_visible():
		utils.scene_changer().transition("LevelSelect.tscn")
        
func _on_text_done():
    $AnimationPlayer.play("idle")
    $Start.show()