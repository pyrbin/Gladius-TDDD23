extends Control

export (bool) var disabled = false
export (Texture) var hp_fill_texture = null

const MAX_DISTANCE_TO_RENDER = 900

onready var life_bar = $Bars/LifeBarWorld/TextureProgress
onready var eng_bar = $Bars/EnergyBarWorld/TextureProgress

var bar_hidden = false
var player

func _ready():
    set_process(not disabled)
    set_physics_process(not disabled)
    set_process_input(not disabled)
    if hp_fill_texture != null:
        life_bar.texture_progress = hp_fill_texture
    show() if not disabled else hide()
    player = get_tree().get_nodes_in_group("Player")[0]
    if not player:
        player.connect("player_loaded", self, "_on_player_loaded")
    else:
        _on_player_loaded()
    
func _on_player_loaded():
    pass

func in_radius_of_player():
    return player.global_position.distance_to(owner.global_position) <= MAX_DISTANCE_TO_RENDER

func _process(delta):
    if owner.dead or not in_radius_of_player():
        if not bar_hidden: 
            hide()
            bar_hidden = true
        return

    life_bar.value = (owner.status.health/owner.status.get_max_health())
    eng_bar.value = (owner.status.endurance/owner.status.get_max_endurance())
    
    if bar_hidden:
        show()
        bar_hidden = false
