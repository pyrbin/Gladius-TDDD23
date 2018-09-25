extends "equippable.gd"
var cooldown = null

func _init(id, name, desc, icon, sprite, slot, stats, cooldown).(id, name, desc, icon, sprite, slot, stats):
    self.cooldown = int(cooldown)

func to_dict(data):
    var dict = .to_dict(data)
    dict["COOLDOWN"] = cooldown
    return dict