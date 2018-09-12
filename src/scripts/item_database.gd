# Singletone database of all items
# Stores and serializes items from json

extends Node

const Equippable = preload("res://scenes/inventory/equippable.gd")
const ItemData = preload("res://scenes/inventory/item_data.gd")

var _url_database_item = "res://scripts/db.json"
var _item_database = {}

func _ready():
    var db_string = DataParser.load_data(_url_database_item)
    for i in db_string:
        var it = db_string[i]
        var int_id = int(i)
        match int(it["TYPE"]):
            ItemData.ITEM_TYPE.EQUIPPABLE:
                _item_database[int_id] = Equippable.new(int_id, it["NAME"], it["ICON"], it["SLOT"], it["ATTRIBUTES"])

func has_item(id):
    return _item_database.has(id)

func get_item(id):
    if not _item_database.has(id):
        return null
    return _item_database[id]