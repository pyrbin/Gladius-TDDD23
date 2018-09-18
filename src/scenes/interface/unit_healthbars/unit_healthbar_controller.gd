extends Control

var enemies
var player

func _ready():
    player = get_tree().get_nodes_in_group("Player")[0]
    if not player:
        player.connect("player_loaded", self, "_on_player_loaded")
    else:
        _on_player_loaded()
    
func _on_player_loaded():
	pass

func _process(delta):
	var i = 0
	enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if enemy.position.distance_to(player.position) > 200: continue
		i+=1
	print(i)
