extends Control

onready var marker = $Marker
onready var tween = $Tween
var player

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    player.connect("attacking", self, "_on_player_attack")
    tween.connect("tween_completed", self, "_on_indicator_complete")

func _on_player_attack():
    if !player.weapon: return
    var speed = player.weapon.data.attributes["COOLDOWN"]
    play_cooldown_indicator(speed)

func play_cooldown_indicator(speed):
    show()
    tween.interpolate_property(marker, "rect_position", Vector2(0, -2), Vector2(49,-2), speed,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    tween.start()

func _on_indicator_complete(obj, path):
    hide()