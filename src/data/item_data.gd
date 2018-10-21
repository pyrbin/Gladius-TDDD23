
enum ITEM_TYPE { MISC, EQUIPPABLE }

const ASSETS_PATH = "res://assets/items/"

var id 
var name
var desc
var icon
var type

func _init(id, type, name, desc, icon):
	self.id = int(id)
	self.type = int(type)
	self.name = name
	self.icon = ASSETS_PATH + icon
	self.desc = desc

func to_dict(object):
	return { 
		"ID": object.id, 
		"NAME": object.name,
		"DESC": object.desc,
		"TYPE": object.type, 
		"ICON": object.icon  
	}
