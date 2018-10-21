extends Control

func _on_space_selected():
	utils.scene_changer().transition("StartScreen.tscn")
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		_on_space_selected()