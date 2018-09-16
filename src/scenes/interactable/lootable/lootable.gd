extends "../interactable.gd"

export (String) var lootable_name
export (Texture) var texture
export (Array, int) var container_items = []
export (Array, int) var container_slots_types = []

onready var container = null

var open_container = false

const MAX_DISTANCE = 140

func _ready():
    container = load("res://scripts/item_container/item_container.gd").new()
    container.init(container_slots_types, container_items)
    container.connect("value_changed", self, "_on_loot_change")
    sprite.set_texture(texture)

func get_action_string():
    return "open: [code][color=blue][b] "+lootable_name+" [/b][/color][/code] \n"

# TODO: this function is not DRY, repeated in "scenes/interactable/lootable/lootable.gd"
func drop_item(index, item_container = container, offset = Vector2(0, -10)):
    var item = container.get(index)
    container.delete(index)
    if item == null: return
    var instance = load("res://scenes/interactable/item/Item.tscn").instance()
    get_tree().get_nodes_in_group("Root_Items")[0].add_child(instance)
    instance.set_item(item)
    instance.position = global_position + offset

func interact():
    var c = 0
    for i in range(0, container.size()):
        if container.get(i) == null: continue
        drop_item(i, container, Vector2(-50 + (c * 20), 0))
        c+=1
    interactable = false
    player.queue_interactable(self, false)
    queue_free()

func _on_loot_change(slot):
    pass

