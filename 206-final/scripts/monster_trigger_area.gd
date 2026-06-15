extends Area3D

@export var target_monster: CharacterBody3D

func _ready():
	var barricades = get_tree().get_nodes_in_group("Barricades")
	for barricade in barricades:
		if barricade:
			barricade.hide()
			barricade.process_mode = Node.PROCESS_MODE_DISABLED

func _on_body_entered(body):
	if body.name == "Player":
		if target_monster and target_monster.has_method("start_chase"):
			target_monster.start_chase()
		
		var barricades = get_tree().get_nodes_in_group("Barricades")
		for barricade in barricades:
			if barricade:
				barricade.show()
				barricade.process_mode = Node.PROCESS_MODE_INHERIT
			
		queue_free()
