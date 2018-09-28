extends HBoxContainer

export (Vector2) var item_size = Vector2()
export (PackedScene) var item_slot_scene = null
var selected = null

# TODO: add array to store items slots not the node hierachy

func _ready():
    pass

func set_item_icon(index, icon):
    if _invalid_index(index): return
    get_child(index).set_item_icon(icon)

func set_item_metadata(index, meta_data):
    if _invalid_index(index): return
    get_child(index).set_item_metadata(meta_data)

func set_item_tooltip(index, tooltip):
    if _invalid_index(index): return
    get_child(index).set_item_tooltip(tooltip)

func set_item_tooltip_enabled(index, enabled):
    if _invalid_index(index): return
    get_child(index).set_tooltip_enabled(enabled)

func add_item():
    var item_scene = item_slot_scene
    var item_slot = item_scene.instance()
    item_slot.set_item_size(item_size)
    add_child(item_slot)
    set_size(get_full_size())
    rect_min_size = get_full_size()

func get_full_size():
    var x_size = item_size.x * get_child_count()
    var x_size_offset = get_child_count() * 4 - 4
    return Vector2(x_size + x_size_offset, item_size.y)

func clear():
    if (get_child_count() == 0): return
    for i in range(0, get_child_count()):
        delete_item(i)

func delete_item(index):
    if _invalid_index(index): return
    remove_child(index)
    set_size(get_full_size())
    rect_min_size = get_full_size()

func get_item(index):
    if index != typeof(TYPE_INT) || index < 0: return null
    return get_child(index)

func get_item_at_position(position):
    var idx = -1
    for i in range(0, get_child_count()):
        var child = get_child(i)
        if child.get_rect().has_point(position):
            idx = i
            break

    return idx

func is_selected(index):
    var item = get_item(index)
    if item == null: return false
    return item.selected

func is_focused(index):
    var item = get_item(index)
    if item == null: return false
    return item.focused

func _invalid_index(index):
    return index == null or get_child(index) == null

func select(index):
    if selected:
        get_item(selected).set_selected(false)
    var item = get_item(index)
    if item == null: return
    item.set_selected(true)
    selected = index

func unselect(index):
    get_item(index).set_selected(false)
    if index == selected:
        selected = null
