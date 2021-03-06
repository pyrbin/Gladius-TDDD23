extends Control
#TODO: Fix selection on hover and drag, only works for legs atm!

export (PackedScene) var key_slot_scene
export (NodePath) onready var item_menu = get_node(item_menu)

signal on_disconnect

const ItemData = preload("res://data/item_data.gd")
const Equippable = preload("res://data/equippable.gd")

const EMPTY_IMAGE_PATH = "res://assets/slot_0.png"
const HELM_IMAGE_PATH = "res://assets/slot_1.png"
const CHEST_IMAGE_PATH = "res://assets/slot_2.png"
const LEGS_IMAGE_PATH = "res://assets/slot_3.png"
const WEAPON_IMAGE_PATH = "res://assets/slot_4.png"
const CONSUMABLE_IMAGE_PATH = "res://assets/slot_5.png"
const UNKNOWN_ICON_PATH = "res://assets/items/unknown_icon.png"

onready var container_list = $Panel/ItemList
onready var item_menu_icon = null
onready var item_menu_info = null
onready var dragged_item_sprite = $Panel/DraggedItem_Sprite

var selected_item_index = null
var dragged_item_index = null
var hovered_item_index = null
var hovered_controller = self

var is_dragging_item = false
var cursor_inside_container_list = false
var mouse_button_released = true

var item_container = null
var item_container_owner = null
var _connected_container_controllers = []

var _item_keys = []

func _ready():
    set_process(false)
    hovered_controller = self

func connect_controller(controller):
    if not _connected_container_controllers.has(controller):
        _connected_container_controllers.append(controller)

func set_cooldown(duration):
    container_list.get_item(1).set_cooldown(duration)

func disconnect_controller(controller):
    var idx = _connected_container_controllers.find(controller)
    if idx != -1:
        _connected_container_controllers.remove(idx)

func connect_to_item_container(p_item_container, p_item_container_owner, p_keys = []):
    if item_container:
        disconnect_item_container()
    item_container = p_item_container
    item_container_owner = null
    if p_item_container == null:
        return
    item_container_owner = p_item_container_owner
    _item_keys = p_keys
    _load_items()
    item_container.connect("value_changed", self, "_on_item_container_changed")

func disconnect_item_container():
    if not item_container: return
    container_list.clear()
    emit_signal("on_disconnect")
    item_container.disconnect("value_changed", self, "_on_item_container_changed")
    item_container = null
    item_container_owner = null

func _on_item_container_changed(slot):
    _update_item_slot(slot)

func _load_items():
    container_list.clear()
    for slot in range(0, item_container.size()):
        container_list.add_item()
        if _item_keys and _item_keys[slot]:
            var key = key_slot_scene.instance()
            var item_slot = container_list.get_item(slot)
            key.get_node("Label").set_text(_item_keys[slot])
            # TODO: remove hardcoding of key_item actionbar
            var pos_x = (container_list.item_size.x * (slot+1)) - (container_list.item_size.x/2) - 19 + slot*4
            var pos_y = (container_list.item_size.y) - 14
            key.rect_position = Vector2(pos_x, pos_y)
            add_child(key)
        _update_item_slot(slot)

    var full_size = container_list.get_full_size()
    set_size(full_size)
    rect_min_size = full_size
    $Panel.set_size(full_size)
    $Panel.rect_min_size = full_size

func _input(event):
    if !owner.is_visible(): return

    if (event is InputEventMouseMotion):
        hovered_item_index = _get_hovered_slot()
        if hovered_item_index >= 0 and (hovered_controller.item_container.get(hovered_item_index) or is_dragging_item):
            selected_item_index = hovered_item_index
            hovered_controller.container_list.select(hovered_item_index)

        elif selected_item_index != null && hovered_controller.container_list.is_selected(selected_item_index):
            hovered_controller.container_list.unselect(selected_item_index)

    if (event is InputEventMouseButton):
        if event.button_index == BUTTON_LEFT and event.pressed and hovered_item_index != -1:
            mouse_button_released = false
            _begin_drag_item(hovered_item_index)
        if event.button_index == BUTTON_LEFT and not event.pressed and is_dragging_item:
            mouse_button_released = true
            _end_drag_item(hovered_item_index, hovered_controller)
        if event.button_index == BUTTON_RIGHT and event.pressed and not is_dragging_item and hovered_item_index != -1:
            _on_Container_List_item_rmb_selected(hovered_item_index, Vector2())

func _process(delta):
    if (is_dragging_item):
        dragged_item_sprite.global_position = get_viewport().get_mouse_position()

func _get_hovered_slot():
    var idx = container_list.get_item_at_position(container_list.get_local_mouse_position())

    if idx != -1: 
        hovered_controller = self
        return idx

    for container in _connected_container_controllers:
        if not container.owner.is_visible(): continue
        var remote_m_pos = container.container_list.get_local_mouse_position()
        idx = container.container_list.get_item_at_position(remote_m_pos)
        if idx != -1:
            hovered_controller = container

    return idx
    
func _begin_drag_item(index):
    if is_dragging_item or index == -1 or index == null: 
        return
    if item_container.get(index) == null:
        return
    var item = container_list.get_item(index)
    if item == null: return
    set_process(true)
    dragged_item_sprite.set_texture(item.item_icon)
    dragged_item_sprite.show()
    _set_empty(index)
    dragged_item_index = index
    is_dragging_item = true
    if selected_item_index:
        hovered_controller.container_list.unselect(selected_item_index)


func _end_drag_item(index, container):
    set_process(false)
    dragged_item_sprite.hide()
    is_dragging_item = false
    if index == -1 or index == null:
        item_container_owner.drop_item(dragged_item_index, item_container)
    if container != self:
        if container.owner.is_visible():
            transfer_item(dragged_item_index, index, container)
        else:
            item_container_owner.drop_item(dragged_item_index, item_container)
    else:
        item_container.move_item(dragged_item_index, index)
    dragged_item_index = null

func transfer_item(from, to, to_container):
    var item_from = item_container.get(from)
    var item_to = to_container.item_container.get(to)
    if to_container.item_container.set(to, item_from):
        item_container.set(from, item_to)
    else:
        _update_item_slot(from)

func _on_Container_List_item_rmb_selected(index, at_position):
    var item = container_list.get_item(index)
    if item == null:
        return
    var item_data = item.item_meta_data
    if item_data == null:
        return
    item_menu = get_tree().get_nodes_in_group("ItemMenu")[0]
    item_menu_icon = item_menu.get_node("ItemMenu_Icon")
    item_menu_info = item_menu.get_node("ItemMenu_Info")
    
    item_menu.set_title("")
    item_menu_icon.set_texture(load(item_data.icon))

    var str_item_info = "[color=yellow]NAME: [/color]" + item_data.name + "\n"
    match item_data.type:
        ItemData.ITEM_TYPE.EQUIPPABLE:
            str_item_info += "[color=blue]SLOT: [/color]" + gb_ItemDatabase.get_slot_str(item_data.slot) + "\n"
            if item_data.slot == Equippable.SLOT.WEAPON:
                str_item_info += "[color=red]DAMAGE: [/color]" + String(item_data.damage) + "\n"
                str_item_info += "[color=teal]COOLDOWN: [/color]" + String(item_data.cooldown) + "\n"
            for stat in item_data.stats:
                var mods = item_data.stats[stat]
                str_item_info += "[color=purple]"+ stat +": [/color]"
                for i in range(0, mods.size()):
                    var mod = mods[i]
                    var postfix = ("%" if mod.mod == "PERCENT" else "")
                    str_item_info += String(mod.value) + postfix
                    if i != mods.size()-1:
                        str_item_info+=", "
                str_item_info += "\n"

    str_item_info += "\n" + item_data.desc + ""
    item_menu_info.set_bbcode(str_item_info)
    item_menu.popup()

func _on_Container_List_mouse_entered():
    cursor_inside_container_list = true

func _on_Container_List_mouse_exited():
    cursor_inside_container_list = false

func _update_item_slot(slot):
    if slot == -1 or slot == null: return
    var item_id = item_container.get(slot)
    if item_id == null: 
        _set_empty(slot)
        return
    var item = gb_ItemDatabase.get_item(item_id)
    if item == null:
        _set_empty(slot)
        return
    var icon = load(item.icon)
    container_list.set_item_icon(slot, icon if icon != null else load(UNKNOWN_ICON_PATH))
    container_list.set_item_metadata(slot, item)
    container_list.set_item_tooltip(slot, item.name)
    container_list.set_item_tooltip_enabled(slot, true)

func _set_empty(slot):
    container_list.set_item_icon(slot, _get_slot_image(slot))
    container_list.set_item_metadata(slot, null)
    container_list.set_item_tooltip(slot, "")
    container_list.set_item_tooltip_enabled(slot, false)

func _get_slot_image(slot):
    match item_container.get_type(slot):
        Equippable.SLOT.HELM:
            return load(HELM_IMAGE_PATH)
        Equippable.SLOT.CHEST:
            return load(CHEST_IMAGE_PATH)
        Equippable.SLOT.LEGS:
            return load(LEGS_IMAGE_PATH)
        Equippable.SLOT.WEAPON:
            return load(WEAPON_IMAGE_PATH)
        Equippable.SLOT.SPECIAL:
            return load(CONSUMABLE_IMAGE_PATH)
    return load(EMPTY_IMAGE_PATH)


func _on_ItemContainerController_mouse_entered():
	cursor_inside_container_list = true


func _on_ItemContainerController_mouse_exited():
	cursor_inside_container_list = false
