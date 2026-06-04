extends Area3D

func _on_body_entered(body):
	# Sadece Player girdiğinde çalışsın
	if body.name == "Player":
		
		# --- 0. SİLAH UI GÖSTERİMİ ---
		if body.has_method("show_weapon_pickup_ui"):
			body.show_weapon_pickup_ui()
			
		# --- 1. KAPIYI ANİMASYONLA DÖNDÜR ---
		var kapilar = get_tree().get_nodes_in_group("HedefKapi")
		for kapi in kapilar:
			kapi.rotation_degrees.z = -180.0
				
		# --- 2. KİLİDİ GÖRÜNÜR YAP ---
		var padlocks = get_tree().get_nodes_in_group("KirmiziKilit")
		for red_pad in padlocks:
			if red_pad:
				red_pad.show() 
				
		# --- 3. ALTYAZI ALANINI UYANDIR ---
		var pad_subs = get_tree().get_nodes_in_group("EvKilitAltyazi")
		for red_sub in pad_subs:
			if red_sub:
				red_sub.process_mode = Node.PROCESS_MODE_INHERIT
				
		# --- 4. TETİKLEYİCİYİ SİL ---
		queue_free()
