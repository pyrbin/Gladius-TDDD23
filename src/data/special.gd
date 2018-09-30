extends "equippable.gd"

const Modifier = preload("modifier.gd")

var cooldown = null
var effects = {}

func _init(id, name, desc, icon, sprite, slot, stats, cooldown, effects).(id, name, desc, icon, sprite, slot, stats):
    self.cooldown = int(cooldown)
    for ekey in effects:
        var special_modifiers = []
        var modifiers = effects[ekey]["MODIFIERS"]
        for stat in modifiers:
            for mod in modifiers[stat]:
                var value = modifiers[stat][mod]
                special_modifiers.append(Modifier.new(stat, mod, value))
        self.effects[ekey] = {
            "MODIFIERS" : special_modifiers,
            "DURATION" : effects[ekey]["DURATION"],
            "INTERVAL" : effects[ekey]["INTERVAL"]
        }

func to_dict(data):
    var dict = .to_dict(data)
    dict["COOLDOWN"] = cooldown
    return dict