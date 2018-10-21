extends Node2D

export (Array) var hairs = []
export (Array) var chests = []
export (bool) var random_hair_color = true
export (bool) var random_skin_color = true

onready var body = $Visuals/Body
onready var r_hand = $Visuals/Equipments/RHand
onready var l_hand = $Visuals/Equipments/LHand

onready var hair = $Visuals/Equipments/Helm
onready var chest = $Visuals/Equipments/Chest

var hair_color = Color.white
var skin_color = Color("#ffb695")
    
func dress_up(p_hair, p_chest):
    hair.set_texture(p_hair)
    chest.set_texture(p_chest)
    body.modulate = skin_color
    r_hand.modulate = skin_color
    l_hand.modulate = skin_color
    hair.modulate = hair_color

func _ready():
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

    if random_skin_color:
        skin_color = skin_tones[randi()%len(skin_tones)]
    if random_hair_color:
        hair_color = hair_tones[randi()%len(hair_tones)]

    dress_up(hairs[randi()%len(hairs)], chests[randi()%len(chests)])

