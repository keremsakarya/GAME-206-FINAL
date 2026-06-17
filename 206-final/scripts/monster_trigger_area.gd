extends Area3D

@export var target_monster: CharacterBody3D

func _ready():
	# Oyun başlar başlamaz barikatları gizle
	var barricades = get_tree().get_nodes_in_group("Barricades")
	for barricade in barricades:
		if barricade:
			barricade.hide()
			barricade.process_mode = Node.PROCESS_MODE_DISABLED

func _on_body_entered(body):
	if body.name == "Player":
		
		# 1. Canavarı Harekete Geçir
		if target_monster and target_monster.has_method("start_chase"):
			target_monster.start_chase()
			
		# 2. Bitiş Çizgisini (EndGameArea) Uyandır
		# Bu komutu tepeye değil, tam ihtiyaç duyduğumuz bu anın içine aldık
		var bitis_alanlari = get_tree().get_nodes_in_group("BitisAlani")
		for alan in bitis_alanlari:
			if alan:
				alan.set_deferred("monitoring", true)
		
		# 3. Barikatları Kapat
		var barricades = get_tree().get_nodes_in_group("Barricades")
		for barricade in barricades:
			if barricade:
				barricade.show()
				barricade.process_mode = Node.PROCESS_MODE_INHERIT
			
		# 4. Bu tetikleyiciyi yok et
		queue_free()
