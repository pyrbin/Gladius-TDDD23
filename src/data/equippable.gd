extends "item_data.gd"
const Modifier = preload("modifier.gd")
enum SLOT { NONE, HELM, CHEST, LEGS, WEAPON, SPECIAL }

var slot = null
var stats = {}
var sprite = ""

func _init(id, name, desc, icon, sprite, slot, stats).(id, ITEM_TYPE.EQUIPPABLE, name, desc, icon):
    self.slot = int(slot)
    self.sprite = ASSETS_PATH + sprite
    for modifier in stats:
        if not self.stats.has(modifier): self.stats[modifier] = []
        for mod in stats[modifier]:
            self.stats[modifier].append(Modifier.new(modifier, mod, stats[modifier][mod]))

# TODO: fix stats to dict transform
func to_dict(data):
    var dict = .to_dict(data)
    dict["SLOT"] = slot
    dict["SPRITE"] = sprite.split(ASSETS_PATH)[0]
    dict["STATS"] = stats
    return dict