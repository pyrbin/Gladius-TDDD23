extends HBoxContainer

var player

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    if not player.action_equipment:
        player.connect("player_loaded", self, "_on_player_loaded")
    else:
        _on_player_loaded()
    
func _on_player_loaded():
    $ActionSlotContainer.connect_to_item_container(player.action_equipment, player)


