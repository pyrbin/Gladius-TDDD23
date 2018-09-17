extends CenterContainer

export (Texture) var normal_texture = null
export (Texture) var selected_texture = null
export (Texture) var focused_texture = null

var item_size = Vector2() setget set_item_size
var item_meta_data = null setget set_item_metadata
var item_icon = null setget set_item_icon
var item_tooltip = "" setget set_item_tooltip
var item_tooltip_enabled = false setget set_tooltip_enabled
var selected = false
var focused = false

func set_item_size(size):
	item_size = size
	$Slot.set_size(item_size)
	$Item.set_size(item_size-Vector2(24, 24))
	
func set_item_metadata(metadata):
	item_meta_data = metadata
	
func set_focused(enable):
	$Slot.texture = focused_texture if enable else normal_texture
	focused = enable

func set_selected(enable):
	$Slot.texture = selected_texture if enable else normal_texture
	selected = enable

func set_item_icon(icon):
	item_icon = icon
	$Item.texture = item_icon
	if icon == null:
		$Item.hide()
	else:
		$Item.show()

func set_item_tooltip(tooltip):
	item_tooltip = tooltip

func set_tooltip_enabled(enabled):
	item_tooltip_enabled = enabled
	