extends Node3D

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	
	for player_node in players:
		if player_node:
			var pistol = player_node.get_node_or_null("Camera3D/Pistol")
			
			if pistol:
				pistol.show()
