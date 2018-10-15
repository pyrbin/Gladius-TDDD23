extends Panel

var toggle = false

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        hide() if toggle else show()

func show():
    toggle = true
    utils.pause_game(true)
    return .show()

func hide():
    toggle = false
    utils.pause_game(false)
    return .hide()

func _on_Start_pressed():
    utils.pause_game(false)
    utils.scene_changer().transition("StartScreen.tscn")

func _on_Exit_pressed():
    utils.pause_game(false)
    get_tree().quit()
