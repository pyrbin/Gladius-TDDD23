extends HBoxContainer

export (Texture) var stat_icon = null
export (String) var stat_name = "VITALITY"
export (int) var stat_value = 100
export (float) var stat_mod_value = 50
export (float) var stat_mod_percent = 100

onready var stat = $Stat
onready var value = $Value
onready var mods = $Mods
onready var icon = $Icon

func _ready():
    set_stat(stat_name)
    set_value(stat_value)
    set_stat_mod_value(stat_mod_value)
    set_stat_mod_percent(stat_mod_percent)
    set_icon(stat_icon)

func set_icon(p_icon):
    stat_icon = p_icon
    icon.texture = p_icon

func set_stat(p_stat):
    stat_name = p_stat
    stat.set_text(stat_name)

func set_value(p_value):
    stat_value = p_value
    value.set_text(String(stat_value))

func set_stat_mod_value(p_mod_value):
    stat_mod_value = p_mod_value
    mods.set_text("+"+String(stat_mod_value)+", "+String(stat_mod_percent)+"%")

func set_stat_mod_percent(p_mod_perc):
    stat_mod_percent = p_mod_perc
    mods.set_text("+"+String(stat_mod_value)+", "+String(stat_mod_percent)+"%")
