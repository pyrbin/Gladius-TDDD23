extends Panel

onready var vitality = $Content/StatsContainer/VBoxContainer/Vitality
onready var power = $Content/StatsContainer/VBoxContainer/Power
onready var atk_speed = $Content/StatsContainer/VBoxContainer/Atk_Speed
onready var mov_speed = $Content/StatsContainer/VBoxContainer/Mov_Speed
onready var crit = $Content/StatsContainer/VBoxContainer/Crit

const ATTR = preload("res://scenes/units/unit_attr.gd")

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
    player.attr.connect("attribute_changed", self, "_on_attr_changed")
    for attr in [ATTR.VITALITY, ATTR.POWER, ATTR.ATK_SPEED, ATTR.MOV_SPEED, ATTR.CRIT]:
        _on_attr_changed(attr)

func _on_attr_changed(stat_key):
    var label = null
    var value = player.attr.final_stat(stat_key)
    var mod_perc = player.attr.get_modifier(stat_key, "PERCENT")
    var mod_val = player.attr.get_modifier(stat_key, "VALUE")
    match stat_key:
        ATTR.POWER     : label = power
        ATTR.VITALITY  : label = vitality
        ATTR.ATK_SPEED : label = atk_speed
        ATTR.MOV_SPEED : label = mov_speed
        ATTR.CRIT      : label = crit
    label.set_value(value)
    label.set_stat_mod_value(mod_val)
    label.set_stat_mod_percent(mod_perc)
