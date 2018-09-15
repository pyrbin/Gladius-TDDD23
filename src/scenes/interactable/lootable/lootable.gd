extends "../interactable.gd"

export (String) var lootable_name
export (Texture) var texture
export (Array, int) var container_items = []
export (Array, int) var container_slots_types = []
export (NodePath) onready var container_controller = get_node(container_controller)

onready var container = null

var open_container = false

const MAX_DISTANCE = 140

func _ready():
    container = load("res://scenes/item_container/item_container.gd").new()
    container.init(container_slots_types, container_items)
    container.connect("value_changed", self, "_on_loot_change")
    sprite.set_texture(texture)

func get_action_string():
    return "open: [code][color=blue][b] "+lootable_name+" [/b][/color][/code] \n"

func interact():
    var c = 0
    for i in range(0, container.size()):
        if container.get(i) == null: continue
        container_controller.drop_item(i, container, self, Vector2(-50 + (c * 20), 0))
        c+=1
    interactable = false
    player.queue_interactable(self, false)
    queue_free()

func _on_loot_change(slot):
    pass

