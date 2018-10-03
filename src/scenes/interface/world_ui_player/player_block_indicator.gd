extends Control

onready var shield = $TextureProgress
onready var ready_shield = $NinePatchRect

var player
var progress

func _ready():
    player = owner
    player.connect("blocking", self, "_on_player_block")
    set_process(false)
    hide()

func _on_player_block():
    if not player.blocking: return
    set_process(true)
    ready_shield.show()
    shield.value = 1
    progress = true
    show()

func _process(d):
    var val = 1 - (player.block_timer.time_left/player.block_timer.wait_time)
    if progress && not player.blocking && !player.block_timer.is_stopped():
        shield.value = val
        if ready_shield.is_visible():
            ready_shield.hide()
    elif progress && not player.blocking && player.block_timer.is_stopped():
        hide()
        set_process(false)
        progress = false


