extends Control

#   TODO:
#   create a manager class that handles containers & player input
#   rename inventory controllers/items to containers


const Inventory = preload("inventory.gd")
const ItemData = preload("item_data.gd")

const EMPTY_IMAGE_PATH = "res://assets/empty_slot.png"

onready var inventory_list = $Panel/Inventory_List
onready var item_menu = $Panel/ItemMenu_WindowDialog
onready var item_menu_icon = $Panel/ItemMenu_WindowDialog/ItemMenu_Icon
onready var item_menu_info = $Panel/ItemMenu_WindowDialog/ItemMenu_Info
onready var dragged_item_sprite = $Panel/DraggedItem_Sprite

var selected_item_index = null
var dragged_item_index = null
var hovered_item_index = null
var hovered_container = self

var is_dragging_item = false
var cursor_inside_inventory_list = false
var mouse_button_released = true

var inventory = null
var _connected_containers = []

func _ready():
    inventory_list.set_fixed_icon_size(Vector2(96,96))
    inventory_list.set_icon_mode(ItemList.ICON_MODE_TOP)
    inventory_list.set_select_mode(ItemList.SELECT_SINGLE)
    inventory_list.set_same_column_width(true)
    inventory_list.set_allow_rmb_select(true)
    #inventory_list.set_size(Vector2(96*MAX_SIZE, 107))
    set_process(false)
    hovered_container = self

func connect_container(container):
    if not _connected_containers.has(container):
        _connected_containers.append(container)

func disconnect_container(container):
    var idx = _connected_containers.find(container)
    if idx != -1:
        _connected_containers.remove(idx)

func connect_to_inventory(p_inventory):
    if inventory:
        inventory.clear()
        inventory.disconnect("value_changed", self, "_on_inventory_changed")
    inventory = p_inventory
    if p_inventory == null:
        return
    inventory_list.set_max_columns(inventory.size())
    _load_items()
    inventory.connect("value_changed", self, "_on_inventory_changed")

func drop_item(index):
    var item = inventory.get(index)
    inventory.delete(index)
    
func _on_inventory_changed(slot):
    _update_item_slot(slot)

func _load_items():
    inventory_list.clear()
    for slot in range(0, inventory.size()):
        inventory_list.add_item("", null, true)
        _update_item_slot(slot)

func _input(event):
    if (event is InputEventMouseMotion):
        hovered_item_index = _get_hovered_slot()
        if hovered_item_index >= 0 and (hovered_container.inventory.get(hovered_item_index) or is_dragging_item):
            hovered_container.inventory_list.select(hovered_item_index, true)
    if (event is InputEventMouseButton):
        if event.button_index == BUTTON_LEFT and event.pressed and cursor_inside_inventory_list:
            mouse_button_released = false
            _begin_drag_item(hovered_item_index)
        if event.button_index == BUTTON_LEFT and not event.pressed and is_dragging_item:
            mouse_button_released = true
            _end_drag_item(hovered_item_index, hovered_container)

func _process(delta):
    if (is_dragging_item):
        dragged_item_sprite.global_position = get_viewport().get_mouse_position()

func _get_hovered_slot():
    var idx = inventory_list.get_item_at_position(inventory_list.get_local_mouse_position(), true)

    if idx != -1: 
        hovered_container = self
        return idx

    for container in _connected_containers:
        if not container.is_visible(): continue
        var remote_m_pos = container.inventory_list.get_local_mouse_position()
        idx = container.inventory_list.get_item_at_position(remote_m_pos, true)
        if idx != -1:
            hovered_container = container

    return idx
    
func _begin_drag_item(index):

    if is_dragging_item or index == -1 or index == null: 
        return
    if inventory.get(index) == null:
        return

    set_process(true)
    dragged_item_sprite.set_texture(inventory_list.get_item_icon(index))
    dragged_item_sprite.show()
    _set_empty(index)
    dragged_item_index = index
    is_dragging_item = true

func _end_drag_item(index, container):
    set_process(false)
    dragged_item_sprite.hide()
    is_dragging_item = false
    if index == -1 or index == null: 
        drop_item(dragged_item_index)
    if container.is_visible() and container != self:
        transfer_item(dragged_item_index, index, container)
    else:
        inventory.move_item(dragged_item_index, index)
    dragged_item_index = null

func transfer_item(from, to, to_container):
    var item_from = inventory.get(from)
    var item_to = to_container.inventory.get(to)
    to_container.inventory.set(to, item_from)
    inventory.set(from, item_to)

func _on_Inventory_item_rmb_selected(index, at_position):
    var item_data = inventory_list.get_item_metadata(index)
    
    if item_data == null:
        return

    item_menu.set_position(get_viewport().get_mouse_position())
    item_menu.set_title(item_data.name)
    item_menu_icon.set_texture(inventory_list.get_item_icon(index))

    var str_item_info = ""
    str_item_info = "Name: " + item_data.name + "\n"
    str_item_info += "Type: " + String(item_data.type) + "\n"
    
    match item_data.type:
        ItemData.ITEM_TYPE.EQUIPPABLE:
            str_item_info += "Slot: " + String(item_data.slot) + "\n"

    str_item_info += "\n" + item_data.desc + ""
    item_menu_info.set_bbcode(str_item_info)
    selected_item_index = index
    item_menu.popup()

func _on_Inventory_List_mouse_entered():
    cursor_inside_inventory_list = true

func _on_Inventory_List_mouse_exited():
    cursor_inside_inventory_list = false

func _update_item_slot(slot):
    if slot == -1 or slot == null: return
    var item_id = inventory.get(slot)
    if item_id == null: 
        _set_empty(slot)
        return
    var item = ItemDatabase.get_item(item_id)
    if item == null:
        _set_empty(slot)
        return
    inventory_list.set_item_icon(slot, load(item.icon))
    inventory_list.set_item_metadata(slot, item)
    inventory_list.set_item_tooltip(slot, item.name)
    inventory_list.set_item_selectable(slot, true)
    inventory_list.set_item_tooltip_enabled(slot, true)

func _set_empty(slot):
    inventory_list.set_item_icon(slot, load(EMPTY_IMAGE_PATH))
    inventory_list.set_item_metadata(slot, null)
    inventory_list.set_item_selectable(slot, false)
    inventory_list.set_item_tooltip(slot, "")
    inventory_list.set_item_tooltip_enabled(slot, false)

func _on_Button_pressed():
    if not inventory:
        return
    inventory.append(randi()%3)

func _on_Button2_pressed():
    if not inventory:
        return
    inventory.delete(randi()%6)