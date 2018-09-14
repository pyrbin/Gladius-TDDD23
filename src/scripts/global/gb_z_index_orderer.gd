extends Node

func _process(delta):
    _set_z_index()
    
class SortOnYPos:
    static func sort(a, b):
        if a.global_position.y < b.global_position.y:
            return true
        return false

func _set_z_index():
    var nodes = get_tree().get_nodes_in_group("Z_Index")
    nodes.sort_custom(SortOnYPos, "sort")
    var i = 0
    if nodes == null: return
    for node in nodes:
        node.z_index = i * 10
        i+=1
