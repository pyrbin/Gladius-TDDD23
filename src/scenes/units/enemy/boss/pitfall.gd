extends Node2D

func _on_SpikeTrap_trigger():
	yield(utils.timer(0.5), "timeout")
	queue_free()