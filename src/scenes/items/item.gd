extends Area2D

const Equippable = preload("equippable.gd")
const ItemData = preload("item_data.gd")
const UNKNOWN_ICON_PATH = "res://assets/items/unknown_icon.png"

export (int) var item_id

onready var anim = $AnimationPlayer
onready var sprite = $Position2D/Sprite
onready var item_data = null
onready var outline_color = sprite.material.get_shader_param("outline_color")

func _ready():
	var mat = sprite.get_material().duplicate(true)
	sprite.set_material(mat)
	connect("body_entered", self, "_on_Item_body_entered")
	connect("body_exited", self, "_on_Item_body_exited")
	set_item(item_id)
	
func set_item(item_id):
	var item = gb_ItemDatabase.get_item(item_id)
	if item == null:
		set_visible(false)
		return
	self.item_id = item_id
	item_data = item
	set_visible(true)
	visible = true
	if (sprite && anim):
		var icon = load(item_data.icon)
		sprite.set_texture(icon if icon != null else load(UNKNOWN_ICON_PATH))
		anim.play("idle")
		set_shader_color()

func set_shader_color(color=Color(0,0,0,0)):
	outline_color = color
	sprite.material.set_shader_param("outline_color", outline_color)

func _on_Item_body_entered(body):
	if not body.get("unit_name"): return
	if body.unit_name == "player_one":
		body.set_for_pickup(self, true)

func _on_Item_body_exited(body):
	if not body.get("unit_name"): return
	if body.unit_name == "player_one":
		set_shader_color()
		body.set_for_pickup(self, false)
