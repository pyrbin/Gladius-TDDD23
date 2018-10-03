extends Navigation2D

export (NodePath) onready var nav_polygon = get_node(nav_polygon)
onready var current_navpoly_id = 1

func _ready():
	pass

func _adjust_polygon_pos(p_transform, p_polygon):
	var polygon = PoolVector2Array()
	var final_transform = nav_polygon.transform.inverse() * p_transform

	for vertex in p_polygon:
		polygon.append(final_transform.xform(vertex))

	return polygon

func _modify_nav_poly(p_poly_2d):
	nav_polygon.navpoly.add_outline(_adjust_polygon_pos(p_poly_2d.transform, p_poly_2d.polygon))
	nav_polygon.navpoly.make_polygons_from_outlines()

func rebuild_nav_path():
	navpoly_remove(current_navpoly_id)
	current_navpoly_id = navpoly_add(nav_polygon.navpoly, nav_polygon.get_relative_transform_to_parent(get_parent()))