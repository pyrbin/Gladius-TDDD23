extends Node2D

export (Array) var hairs = []
export (Array) var chests = []

onready var body = $Visuals/Body
onready var r_hand = $Visuals/Equipments/RHand
onready var l_hand = $Visuals/Equipments/LHand

onready var hair = $Visuals/Equipments/Helm
onready var chest = $Visuals/Equipments/Chest

var hair_color = Color.white
var skin_color = Color.white

func _ready():
    $AnimPlayer.play("idle")
    randomize()

    var hair_tones = [
        Color("#090806"),\
        Color("#8D4A43"),\
        Color("#B55239"),\
        Color("#E6CEA8"),\
        Color("#B7A69E"),\
        Color("#B55239"),\
        Color("#090806"),\
        Color("#FFF5E1"),\
        Color("#91553D")]
    var skin_tones = [
        Color("#ffb695"),\
        Color("#784734"),\
        Color("#ff9a6d"),\
        Color("#965738")]

    skin_color = skin_tones[randi()%len(skin_tones)]
    body.modulate = skin_color
    r_hand.modulate = skin_color
    l_hand.modulate = skin_color
    hair.set_texture(hairs[randi()%len(hairs)])
    hair.modulate = hair_tones[randi()%len(hair_tones)]
    chest.set_texture(chests[randi()%len(chests)])
