extends Area3D


@export var target_monster: CharacterBody3D



func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		
		# Eğer canavarı seçtiysek ve canavarın "start_chase" diye bir yeteneği varsa
		if target_monster and target_monster.has_method("start_chase"):
			# Canavara "Saldır!" komutunu gönder ve oyuncunun hedefini ver
			target_monster.start_chase(body)
			
			# Canavar peşine düştükten sonra bu trigger'ı silebiliriz (iki kere çalışmasın)
			queue_free()
