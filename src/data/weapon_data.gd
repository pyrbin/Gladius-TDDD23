extends "equippable.gd"

enum WEAPON_TYPE { SWING, STAB, RANGED }
const WEAPON_PATH = "res://scenes/weapons/"
var weapon_type = null
var model = null
var ammo = null
var damage = null
var attack_speed = null
var cooldown = null

"""
    Must have weapon attributes

    > DAMAGE
    > ATTACK_SPEED
    > COOLDOWN

"""

func _init(id, name, desc, icon, sprite, slot, stats, weapon_type, model, damage, attack_speed, cooldown, ammo=null).(id, name, desc, icon, sprite, slot, stats):
    self.weapon_type = int(weapon_type)
    self.model = WEAPON_PATH + model
    self.damage = damage
    self.attack_speed = attack_speed
    self.cooldown = cooldown
    if ammo:
        self.ammo = ASSETS_PATH + ammo

func to_dict(data):
    var dict = .to_dict(data)
    dict["WEAPON_TYPE"] = weapon_type
    dict["MODEL"] = sprite.split(WEAPON_PATH)[0]
    dict["DAMAGE"] = damage
    dict["ATTACK_SPEED"] = attack_speed
    dict["COOLDOWN"] = cooldown
    dict["AMMO"] = ammo.split(ASSETS_PATH)[0]
    return dict