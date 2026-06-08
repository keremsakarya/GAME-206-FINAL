extends Area3D

@export var target_monster: CharacterBody3D

func _on_body_entered(body):
	if body.name == "Player":
		# Canavar Inspector'dan seçilmişse ve start_chase yeteneği varsa
		if target_monster and target_monster.has_method("start_chase"):
			target_monster.start_chase()
			
			# Kovalamaca başladıktan sonra tetikleyiciyi sil (iki kez çalışmasın)
			queue_free()
