# Singletone database of all items
# Stores and serializes items from json

extends Node

const Equippable = preload("res://scenes/items/equippable.gd")
const WeaponData = preload("res://scenes/items/weapon_data.gd")
const ItemData = preload("res://scenes/items/item_data.gd")

var _url_database_item = "res://data/items.json"
var _item_database = {}

func _ready():
    var db_string = gb_DataParser.load_data(_url_database_item)
    for i in db_string:
        var it = db_string[i]
        var int_id = int(i)
        if it["TYPE"] == ItemData.ITEM_TYPE.EQUIPPABLE and it["SLOT"] != Equippable.SLOT.WEAPON:
            _item_database[int_id] = Equippable.new(
                int_id, 
                it["NAME"],
                it["DESC"],
                it["ICON"],
                it["SPRITE"],
                it["SLOT"], 
                it["ATTRIBUTES"]
            )
        elif it["TYPE"] == ItemData.ITEM_TYPE.EQUIPPABLE and it["SLOT"] == Equippable.SLOT.WEAPON:
            _item_database[int_id] = WeaponData.new(
                int_id, 
                it["NAME"],
                it["DESC"],
                it["ICON"],
                it["SPRITE"],
                it["SLOT"], 
                it["ATTRIBUTES"],
                it["WEAPON_TYPE"],
                it["MODEL"]
            )

func has_item(id):
    return _item_database.has(id)

func get_item(id):
    if not _item_database.has(id):
        return null
    return _item_database[id]