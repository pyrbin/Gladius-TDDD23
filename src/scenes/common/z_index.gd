extends Node

func _process(delta):
	_set_z_index()

func _set_z_index():
    var z_index_offset = int(owner.global_position.y)
    z_index_offset/=3
    owner.z_index = (z_index_offset) + 2000