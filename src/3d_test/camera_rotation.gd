extends Position3D

func _process(delta):
    var main = get_tree().get_nodes_in_group("MainCamera")[0]
    rotation_degrees = Vector3(main.rotation_degrees.x + 90,0,0)
