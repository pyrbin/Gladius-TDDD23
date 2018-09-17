extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var player
var other_controller

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    other_controller = get_tree().get_nodes_in_group("ActionBar_ItemContainer")[0]
    if not player.equipment:
        player.connect("player_loaded", self, "_on_player_loaded")
    else:
        _on_player_loaded()

func _on_player_loaded():
    $Content/CenterContainer/ItemSlotContainer.connect_to_item_container(player.equipment, player)
    #$Content/CenterContainer/ItemSlotContainer.connect_controller(other_controller)
