extends Area3D


func _on_body_entered(body):
	if body.name == "Player" and body.has_method("show_weapon_pickup_ui"):
		body.show_weapon_pickup_ui()
		queue_free()
