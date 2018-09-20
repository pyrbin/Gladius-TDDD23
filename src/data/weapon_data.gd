extends "equippable.gd"

enum WEAPON_TYPE { SWING, STAB, RANGED }
const WEAPON_PATH = "res://scenes/weapons/"
var weapon_type = null
var model = null
var ammo = null

"""
    Must have weapon attributes

    > DAMAGE
    > ATTACK_SPEED
    > COOLDOWN

"""

func _init(id, name, desc, icon, sprite, slot, attributes, weapon_type, model).(id, name, desc, icon, sprite, slot, attributes):
    self.weapon_type = int(weapon_type)
    self.model = WEAPON_PATH + model
    if (attributes.has("AMMO")):
        self.ammo = ASSETS_PATH + attributes["AMMO"]
        self.attributes.erase("AMMO")

func to_dict(data):
    var dict = .to_dict(data)
    dict["WEAPON_TYPE"] = weapon_type
    dict["MODEL"] = sprite.split(WEAPON_PATH)[0]
    if (ammo):
        dict["ATTRIBUTES"]["AMMO"] = ammo.split(ASSETS_PATH)[0]
    return dict