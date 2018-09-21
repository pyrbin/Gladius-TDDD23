extends "item_data.gd"

enum SLOT { NONE, HELM, CHEST, LEGS, WEAPON, SPECIAL }

var slot = null
var attributes = {}
var sprite = ""

func _init(id, name, desc, icon, sprite, slot, attributes).(id, ITEM_TYPE.EQUIPPABLE, name, desc, icon):
    self.slot = int(slot)
    self.sprite = ASSETS_PATH + sprite
    self.attributes = attributes

func to_dict(data):
    var dict = .to_dict(data)
    dict["SLOT"] = slot
    dict["SPRITE"] = sprite.split(ASSETS_PATH)[0]
    dict["ATTRIBUTES"] = attributes
    return dict