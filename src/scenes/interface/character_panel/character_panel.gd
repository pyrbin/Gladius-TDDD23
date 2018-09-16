extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var player


func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    if not player.equipment:
        player.connect("player_loaded", self, "_on_player_loaded")
    else:
        _on_player_loaded()

func _on_player_loaded():
    $Content/EquipmentSlotContainer.connect_to_item_container(player.equipment, player)
