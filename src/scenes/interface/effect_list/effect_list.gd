extends Control

onready var player = null
onready var list = $List
onready var max_effect_icons = 0
onready var effect_data = []

func _ready():
    max_effect_icons = list.get_child_count()
    player = get_tree().get_nodes_in_group("Player")[0]
    effect_data.resize(max_effect_icons)
    if not player.stats:
        player.connect("player_loaded", self, "_on_player_loaded")
    else:
        _on_player_loaded()

    for child in list.get_children():
        child.hide()

func _on_player_loaded():
    player.stats.connect("effect_applied", self, "_on_effect_update")
    player.stats.connect("effect_expired", self, "_on_effect_update")

func _on_effect_update(d):
    pass

func _process(d):
    if not player.stats: return
    var efxs = player.stats.get_effects()
    for i in range(0, len(list.get_children())):
        var item = list.get_child(i)
        if len(efxs) > i:
            item.get_node("Cooldown").set_text(String(int(efxs[i].get_duration() * efxs[i].get_progress())))
            item.show()
        else:
            item.hide()
