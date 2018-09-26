extends Panel

onready var vitality = $Content/StatsContainer/VBoxContainer/Vitality
onready var stamina = $Content/StatsContainer/VBoxContainer/Stamina
onready var power = $Content/StatsContainer/VBoxContainer/Power
onready var atk_speed = $Content/StatsContainer/VBoxContainer/Atk_Speed
onready var mov_speed = $Content/StatsContainer/VBoxContainer/Mov_Speed
onready var crit = $Content/StatsContainer/VBoxContainer/Crit

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
    #  player.attr.connect("attribute_changed", self, "_on_attr_changed")
    # for attr in [ATTR.VITALITY, ATTR.POWER, ATTR.ATK_SPEED, ATTR.MOV_SPEED, ATTR.CRIT]:
    #     _on_attr_changed(attr)

func _process(d):
    if is_visible():
        for attr in player.stats.get_list():
            _attr_update(attr)

func _attr_update(stat_key):
    var label = null
    var final = player.stats.get_stat_info(stat_key)
    var base = player.stats.get_base_stat(stat_key)
    match stat_key:
        STAT.POWER     : label = power
        STAT.VITALITY  : label = vitality
        STAT.STAMINA   : label = stamina
        STAT.ATK_SPEED : label = atk_speed
        STAT.MOVEMENT  : label = mov_speed
        STAT.CRIT      : label = crit

    label.set_value(final.compute(base))
    label.set_stat_mod_value(final.vsum)
    label.set_stat_mod_percent(final.msum)
