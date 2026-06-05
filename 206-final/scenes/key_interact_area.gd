extends Area3D

@export var monster: Node3D
@export var key_mesh: Node3D
@onready var ui_label = $CanvasLayer/InteractLabel

var is_player_near = false
var triggered = false
var player_node: Node3D = null

func _ready():
	if monster: monster.hide()
	if ui_label: ui_label.hide() 

func _unhandled_input(event):
	if is_player_near and not triggered and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			trigger_jumpscare()

func trigger_jumpscare():
	triggered = true
	if ui_label: ui_label.hide() 
	if key_mesh: key_mesh.hide() 
		
	if player_node:
		player_node.has_key = true
		if "can_move" in player_node: player_node.can_move = false
			
		if monster:
			monster.show()
			if player_node.has_method("force_look_at"):
				var wall_pos = monster.global_position
				wall_pos.y += 1.0
				player_node.force_look_at(wall_pos)
		
		await get_tree().create_timer(0.5).timeout
		
		if monster and player_node.has_node("Camera3D"):
			var cam = player_node.get_node("Camera3D")
			var forward_dir = -cam.global_transform.basis.z.normalized()
			var face_to_face_pos = cam.global_position + (forward_dir * 1.2) 
			
			# Adjusted Y offset to 0.0 so he is perfectly eye-level with camera
			face_to_face_pos.y -= 0.0 
			monster.global_position = face_to_face_pos
			
			# Clean Slate Rotation: Wipes wall angle, then rotates to face camera
			# Aim him at the camera
			monster.look_at(cam.global_position, Vector3.UP)
			
			# ADD the rotation to his current angle instead of overwriting it
			# If 90 makes him face left, change to -90, 180, or 270 until he faces you!
			monster.rotate_y(deg_to_rad(90))
			
			if player_node.has_method("force_look_at"):
				var monster_face = monster.global_position
				monster_face.y += 1.4 
				player_node.force_look_at(monster_face)
			
		if player_node.has_method("play_scream"): player_node.play_scream()
		if player_node.has_method("apply_shake"): player_node.apply_shake(1.0, 1.5) 
			
		await get_tree().create_timer(1.5).timeout
		
		if monster: monster.hide() 
		if player_node.has_method("apply_shake"): player_node.apply_shake(0.0, 0.0)
		if player_node.has_method("play_panic_audio"): player_node.play_panic_audio()
			
		await get_tree().create_timer(2.0).timeout
		if "can_move" in player_node: player_node.can_move = true
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not triggered:
		player_node = body
		is_player_near = true
		if ui_label: ui_label.show() 

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_player_near = false
		player_node = null
		if ui_label: ui_label.hide()
