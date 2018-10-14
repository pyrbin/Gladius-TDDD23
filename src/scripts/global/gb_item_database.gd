# Singletone database of all items
# Stores and serializes items from json

extends Node

const Special = preload("res://data/special.gd")
const Equippable = preload("res://data/equippable.gd")
const WeaponData = preload("res://data/weapon_data.gd")
const ItemData = preload("res://data/item_data.gd")

const DATABASES = [
    "wooden.json",
    "iron.json",
    "potions.json",
]

var _item_database = {}

func _ready():
    for collection in DATABASES:
        _load_from_json(collection)
  
func _load_from_json(url):
    var db_string = gb_DataParser.load_data("res://data/json/"+url)
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
                it["COOLDOWN"],
                it["AMMO"] if it.has("AMMO") else null
            )
        elif it["TYPE"] == ItemData.ITEM_TYPE.EQUIPPABLE and it["SLOT"] == Equippable.SLOT.SPECIAL:
            _item_database[int_id] = Special.new(
                int_id, 
                it["NAME"],
                it["DESC"],
                it["ICON"],
                it["SPRITE"],
                it["SLOT"], 
                it["STATS"],
                it["COOLDOWN"],
                it["EFFECTS"]
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

func get_slot_str(slot):
    match slot:
        Equippable.SLOT.HELM: return "Helm"
        Equippable.SLOT.CHEST: return "Chest"
        Equippable.SLOT.LEGS: return "Legs"
        Equippable.SLOT.WEAPON: return "Weapon"
        Equippable.SLOT.SPECIAL: return "Special"

func get_item(id):
    if not _item_database.has(id):
        return null
    return _item_database[id]