extends Area3D

@onready var korku_sesi = $AudioStreamPlayer3D
# Reference the CSGBox3D (Update the name if you named it differently in the scene tree)
@onready var csg_box = $CSGBox3D

func _on_body_entered(body):
	if body.name == "Player":
		
		var kamera = body.get_node_or_null("Camera3D")
		if kamera:
			# Setup a Tween engine for the shake. It will loop 15 times.
			var shake_tween = create_tween().set_loops(15)
			
			# Move the lens slightly up in 0.05 seconds, then down in 0.05 seconds.
			# (0.1 sec x 15 loops = exactly 1.5 seconds of shake)
			shake_tween.tween_property(kamera, "v_offset", 0.2, 0.05)
			shake_tween.tween_property(kamera, "v_offset", -0.2, 0.05)
			
			# Reset the lens when the shake completely finishes so it doesn't stay skewed:
			shake_tween.finished.connect(func(): kamera.v_offset = 0.0)
		
		# --- 1. PLAY THE SOUND ---
		if korku_sesi:
			korku_sesi.play()
			
		# --- 2. TURN ON THE LIGHTS ---
		var isiklar = get_tree().get_nodes_in_group("MutfakIsik")
		for isik in isiklar:
			if isik:
				isik.show()
				
		# --- 3. THROW OBJECTS IN THE AIR (PHYSICS ENGINE) ---
		var esyalar = get_tree().get_nodes_in_group("UcanEsya")
		for esya in esyalar:
			# Ensure the object is actually a physical object (RigidBody3D)
			if esya is RigidBody3D:
				
				# Generate random numbers so not every object flies in the same direction
				var x_gucu = randf_range(-3.0, 3.0) # Random push left or right
				var y_gucu = randf_range(5.0, 10.0) # Main upward throwing force (between 5 and 10)
				var z_gucu = randf_range(-3.0, 3.0) # Random push forward or backward
				
				# Create the vector and kick the object!
				var firlatma_yonu = Vector3(x_gucu, y_gucu, z_gucu)
				esya.apply_central_impulse(firlatma_yonu)
				
				# If you want to spin the object slightly around itself:
				var dönme_gucu = Vector3(randf_range(-2, 2), randf_range(-2, 2), randf_range(-2, 2))
				esya.apply_torque_impulse(dönme_gucu)
				
		# --- 4. DELETE THE CSGBOX ---
		# Destroy the box to clear the path
		if csg_box:
			csg_box.queue_free()
				
		# --- 5. DISABLE THE TRIGGER ---
		# Disable the physical area instead of immediately freeing the node,
		# so the AudioStreamPlayer3D doesn't get cut off.
		set_deferred("monitoring", false)
