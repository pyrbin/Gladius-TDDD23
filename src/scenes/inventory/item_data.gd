
enum ITEM_TYPE { EQUIPPABLE }

var id 
var name
var icon
var type

func _init(id, type, name, icon):
	self.id = id
	self.type = type
	self.name = name
	self.icon = icon

func to_dict(object):
	return { 
		"ID": object.id, 
		"NAME": object.name, 
		"TYPE": object.type, 
		"ICON": object.icon  
	}
