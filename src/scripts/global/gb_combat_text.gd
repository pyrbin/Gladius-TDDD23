extends Node

onready var CombatText = preload("res://scenes/interface/combat_text/CombatText.tscn") 
onready var GUI = null
onready var text_pool = []

const POOL_SIZE = 30

const HEAL_CLR_NM      = Color.green
const HEAL_CLR_CR      = Color.darkgreen

const DMG_CLR_NM_ENEMY = Color.white
const DMG_CLR_CR_ENEMY = Color.red

const DMG_CLR_NM_PL    = Color.orange
const DMG_CLR_CR_PL    = Color.darkorange

const BLOCK_CLR_ENEMY  = Color.yellow
const FAT_CLR_ENEMY    = Color.darkgreen

func _ready():
	text_pool.resize(POOL_SIZE)
	for i in range(0, POOL_SIZE):
		text_pool[i] = CombatText.instance()
		text_pool[i].is_active = false
	if get_tree().get_nodes_in_group("GUI").size() > 0:
		GUI =  get_tree().get_nodes_in_group("GUI")[0]

func popup(p_hit_info, p_position):
	for i in range(0, POOL_SIZE):
		var combat_text = text_pool[i]
		if not combat_text.is_active:
			add_child(combat_text)
			var player = get_tree().get_nodes_in_group("Player")[0]
			var is_player = p_hit_info.target == player
			var text = get_text_content(p_hit_info, is_player)
			var color = get_text_color(p_hit_info.type, p_hit_info.action, is_player)
			combat_text.display(text, p_position, color)
			break

func get_text_content(p_hit_info, is_player):
	match p_hit_info.action:
		HitInfo.ACTION.BLOCK:
			return "BLOCKED"
		HitInfo.ACTION.HEAL:
			return "+" + String(abs(p_hit_info.amount))
		HitInfo.ACTION.DAMAGE:
			return "-" + String(p_hit_info.amount)


func get_text_color(p_type, p_action, is_player):
	match p_action:
		HitInfo.ACTION.BLOCK:
			return BLOCK_CLR_ENEMY
		HitInfo.ACTION.HEAL:
			return HEAL_CLR_NM if p_type == HitInfo.TYPE.NORMAL else HEAL_CLR_CR
		HitInfo.ACTION.DAMAGE:
			if not is_player:
				return DMG_CLR_NM_ENEMY if p_type == HitInfo.TYPE.NORMAL else DMG_CLR_CR_ENEMY
			else:
				return DMG_CLR_NM_PL if p_type == HitInfo.TYPE.NORMAL else DMG_CLR_CR_PL


class HitInfo:

	enum TYPE {
		NORMAL,
		CRIT
	}
	
	enum ACTION {
		HEAL,
		DAMAGE,
		BLOCK,
		FATIGUE
	}
	
	var attacker = null
	var target = null
	var amount = 0
	var type = null
	var action = null
	
	func _init(p_amount, p_attacker, p_target, p_type, p_action):
		amount = p_amount
		attacker = p_attacker
		target = p_target
		type = p_type
		action = p_action
