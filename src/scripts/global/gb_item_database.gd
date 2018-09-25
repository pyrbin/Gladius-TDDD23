# Singletone database of all items
# Stores and serializes items from json

extends Node

const Consumable = preload("res://data/consumable.gd")
const Equippable = preload("res://data/equippable.gd")
const WeaponData = preload("res://data/weapon_data.gd")
const ItemData = preload("res://data/item_data.gd")

var _url_database_item = "res://data/items.json"
var _item_database = {}

func _ready():
    var db_string = gb_DataParser.load_data(_url_database_item)
    for i in db_string:
        var it = db_string[i]
        var int_id = int(i)
        if it["TYPE"] == ItemData.ITEM_TYPE.EQUIPPABLE and it["SLOT"] == Equippable.SLOT.WEAPON:
            _item_database[int_id] = WeaponData.new(
                int_id, 
                it["NAME"],
                it["DESC"],
                it["ICON"],
                it["SPRITE"],
                it["SLOT"], 
                it["STATS"],
                it["WEAPON_TYPE"],
                it["MODEL"],
                it["DAMAGE"],
                it["ATTACK_SPEED"],
                it["COOLDOWN"],
                it["AMMO"] if it.has("AMMO") else null
            )
        elif it["TYPE"] == ItemData.ITEM_TYPE.EQUIPPABLE and it["SLOT"] == Equippable.SLOT.SPECIAL:
            _item_database[int_id] = Consumable.new(
                int_id, 
                it["NAME"],
                it["DESC"],
                it["ICON"],
                it["SPRITE"],
                it["SLOT"], 
                it["STATS"],
                it["COOLDOWN"]
            )
        elif it["TYPE"] == ItemData.ITEM_TYPE.EQUIPPABLE:
            _item_database[int_id] = Equippable.new(
                int_id, 
                it["NAME"],
                it["DESC"],
                it["ICON"],
                it["SPRITE"],
                it["SLOT"], 
                it["STATS"]
            )

func has_item(id):
    return _item_database.has(id)

func get_item(id):
    if not _item_database.has(id):
        return null
    return _item_database[id]