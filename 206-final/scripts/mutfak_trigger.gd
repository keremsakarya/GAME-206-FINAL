extends Area3D

# Sesi kodun içinde doğrudan buluyoruz
@onready var korku_sesi = $AudioStreamPlayer3D

func _on_body_entered(body):
	if body.name == "Player":
		
		var kamera = body.get_node_or_null("Camera3D")
		if kamera:
			# Titreme için bir Tween motoru kuruyoruz. Toplam 15 kere tekrarlayacak.
			var shake_tween = create_tween().set_loops(15)
			
			# Lensi 0.05 saniyede hafifçe yukarı, sonra 0.05 saniyede aşağı çekiyoruz.
			# (0.1 sn x 15 tekrar = tam 1.5 saniyelik sarsıntı)
			shake_tween.tween_property(kamera, "v_offset", 0.2, 0.05)
			shake_tween.tween_property(kamera, "v_offset", -0.2, 0.05)
			
			# Sarsıntı tamamen bittiğinde lensin yamuk kalmaması için sıfırlıyoruz:
			shake_tween.finished.connect(func(): kamera.v_offset = 0.0)
		
		# --- 1. SESİ ÇAL ---
		if korku_sesi:
			korku_sesi.play()
			
		# --- 2. IŞIKLARI YAK ---
		var isiklar = get_tree().get_nodes_in_group("MutfakIsik")
		for isik in isiklar:
			if isik:
				isik.show()
				
		# --- 3. EŞYALARI HAVAYA FIRLAT (FİZİK MOTORU) ---
		var esyalar = get_tree().get_nodes_in_group("UcanEsya")
		for esya in esyalar:
			# Objenin gerçekten fiziksel bir obje (RigidBody3D) olduğundan emin ol
			if esya is RigidBody3D:
				
				# Her sandalyenin aynı yöne gitmemesi için rastgele (random) sayılar üretiyoruz
				var x_gucu = randf_range(-3.0, 3.0) # Sağa veya sola rastgele itilim
				var y_gucu = randf_range(5.0, 10.0) # YUKARI doğru ana fırlatma gücü (5 ile 10 arası)
				var z_gucu = randf_range(-3.0, 3.0) # İleri veya geri rastgele itilim
				
				# Vektörü oluştur ve sandalyeye tekme at!
				var firlatma_yonu = Vector3(x_gucu, y_gucu, z_gucu)
				esya.apply_central_impulse(firlatma_yonu)
				
				# Objeyi biraz kendi etrafında da döndürmek (spin atmak) istersen:
				var dönme_gucu = Vector3(randf_range(-2, 2), randf_range(-2, 2), randf_range(-2, 2))
				esya.apply_torque_impulse(dönme_gucu)
				
		# --- 4. TETİKLEYİCİYİ SİL ---
		# Sesin yarıda kesilmemesi için queue_free'den önce bekletebilirsin,
		# ama AudioStreamPlayer3D kullanıyorsan ve Area3D silinirse ses de silinir.
		# O yüzden trigger'ı hemen silmek yerine, fiziksek alanı kapatıyoruz:
		set_deferred("monitoring", false)
