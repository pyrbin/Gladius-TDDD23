extends Area2D

const Equippable = preload("equippable.gd")

export (String) var item_data_source
export (Texture) var item_icon

onready var sprite = $Sprite

var item_data

func _ready():
	var file = File.new()
	file.open(item_data_source, file.READ)
	var data = JSON.parse(file.get_as_text())
	if typeof(data.result) != TYPE_DICTIONARY:
		return
	if (data.result["TYPE"] == Equippable.ITEM_TYPE.EQUIPPABLE):
		item_data = Equippable.new(data.result["NAME"], data.result["ICON"], data.result["SLOT"], {
			Equippable.ATTRIBUTE_KEY.HEALTH : 200,
			Equippable.ATTRIBUTE_KEY.STAMINA: 22,
			Equippable.ATTRIBUTE_KEY.SPEED	: 440,
			Equippable.ATTRIBUTE_KEY.DAMAGE	: 11,
		})

	sprite.texture = item_icon
