
enum ITEM_TYPE { MISC, EQUIPPABLE }

var id 
var name
var desc
var icon
var type

func _init(id, type, name, desc, icon):
	self.id = id
	self.type = type
	self.name = name
	self.icon = icon
	self.desc = desc

func to_dict(object):
	return { 
		"ID": object.id, 
		"NAME": object.name,
		"DESC": object.desc,
		"TYPE": object.type, 
		"ICON": object.icon  
	}
