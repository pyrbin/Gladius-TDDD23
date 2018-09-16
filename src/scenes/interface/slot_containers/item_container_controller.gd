extends Control

export (PackedScene) var item_scene

signal on_disconnect

const Container = preload("res://scripts/item_container/item_container.gd")
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
onready var item_menu = $Panel/ItemMenu_WindowDialog
onready var item_menu_icon = $Panel/ItemMenu_WindowDialog/ItemMenu_Icon
onready var item_menu_info = $Panel/ItemMenu_WindowDialog/ItemMenu_Info
onready var dragged_item_sprite = $Panel/DraggedItem_Sprite
onready var items_root_node = get_tree().get_nodes_in_group("Root_Items")[0]

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

func _ready():
    container_list.set_fixed_icon_size(Vector2(96,96))
    container_list.set_icon_mode(ItemList.ICON_MODE_TOP)
    container_list.set_select_mode(ItemList.SELECT_SINGLE)
    container_list.set_same_column_width(true)
    container_list.set_allow_rmb_select(true)
    #container_list.set_size(Vector2(96*MAX_SIZE, 107))
    set_process(false)
    hovered_controller = self

func connect_controller(controller):
    if not _connected_container_controllers.has(controller):
        _connected_container_controllers.append(controller)

func disconnect_controller(controller):
    var idx = _connected_container_controllers.find(controller)
    if idx != -1:
        _connected_container_controllers.remove(idx)

func connect_to_item_container(p_item_container, p_item_container_owner):
    if item_container:
        disconnect_item_container()
    item_container = p_item_container
    item_container_owner = null
    if p_item_container == null:
        return
    item_container_owner = p_item_container_owner
    container_list.set_max_columns(item_container.size())
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
        container_list.add_item("", null, true)
        _update_item_slot(slot)

func _input(event):
    if (event is InputEventMouseMotion):
        hovered_item_index = _get_hovered_slot()
        if hovered_item_index >= 0 and (hovered_controller.item_container.get(hovered_item_index) or is_dragging_item):
            selected_item_index = hovered_item_index
            hovered_controller.container_list.select(hovered_item_index, true)
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
    var idx = container_list.get_item_at_position(container_list.get_local_mouse_position(), true)

    if idx != -1: 
        hovered_controller = self
        return idx

    for container in _connected_container_controllers:
        if not container.is_visible(): continue
        var remote_m_pos = container.container_list.get_local_mouse_position()
        idx = container.container_list.get_item_at_position(remote_m_pos, true)
        if idx != -1:
            hovered_controller = container

    return idx
    
func _begin_drag_item(index):
    if is_dragging_item or index == -1 or index == null: 
        return
    if item_container.get(index) == null:
        return
    set_process(true)
    dragged_item_sprite.set_texture(container_list.get_item_icon(index))
    dragged_item_sprite.show()
    _set_empty(index)
    dragged_item_index = index
    is_dragging_item = true
    hovered_controller.container_list.unselect(selected_item_index)


func _end_drag_item(index, container):
    set_process(false)
    dragged_item_sprite.hide()
    is_dragging_item = false
    if index == -1 or index == null:
        item_container_owner.drop_item(dragged_item_index, item_container)
    if container.is_visible() and container != self:
        transfer_item(dragged_item_index, index, container)
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
    var item_data = container_list.get_item_metadata(index)
    
    if item_data == null:
        return

    item_menu.set_position(get_viewport().get_mouse_position())
    item_menu.set_title(item_data.name)
    item_menu_icon.set_texture(container_list.get_item_icon(index))

    var str_item_info = ""
    str_item_info = "Name: " + item_data.name + "\n"
    str_item_info += "Type: " + String(item_data.type) + "\n"
    
    match item_data.type:
        ItemData.ITEM_TYPE.EQUIPPABLE:
            str_item_info += "Slot: " + String(item_data.slot) + "\n"

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
    container_list.set_item_selectable(slot, true)
    container_list.set_item_tooltip_enabled(slot, true)

func _set_empty(slot):
    container_list.set_item_icon(slot, _get_slot_image(slot))
    container_list.set_item_metadata(slot, null)
    container_list.set_item_selectable(slot, false)
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

func _on_Button_pressed():
    if not item_container:
        return
    item_container.append(randi()%3)

func _on_Button2_pressed():
    if not item_container:
        return
    item_container.delete(randi()%4)