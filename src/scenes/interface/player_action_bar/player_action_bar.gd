extends HBoxContainer

onready var life_bar = $StatusBars/LifeBar/TextureProgress
onready var energy_bar = $StatusBars/MarginContainer/EnergyBar/TextureProgress

var player
var status
var other_controller

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    other_controller = get_tree().get_nodes_in_group("Equipment_ItemContainer")[0]
    if not player.action_equipment:
        player.connect("player_loaded", self, "_on_player_loaded")
    else:
        _on_player_loaded()
    
func _on_player_loaded():
    $MarginContainer/ItemSlotContainer.connect_to_item_container(player.action_equipment, player, ["M1", "Q"])
    status = player.status

func _process(delta):
    if status:
        life_bar.value = (status.health/status.max_health)
        energy_bar.value = float(status.endurance)/status.max_endurance
