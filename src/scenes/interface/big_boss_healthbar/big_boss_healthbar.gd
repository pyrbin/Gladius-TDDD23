extends Control

onready var label = $Label
onready var life_bar = $LifeBar/TextureProgress
onready var life_text = $LifeBar/TextureProgress/Label

var start = false
var status = null
var boss = null

func _ready():
	hide()

func start(p_boss):
	boss = p_boss
	status = boss.status
	start = true
	label.set_text(boss.boss_name)
	show()

func _process(d):
	if not start: return
	life_text.set_text(String(int(status.health)) + "/" + String(int(status.get_max_health())))
	life_bar.value = (status.health/status.get_max_health())