extends Area3D

@export var monster: Node3D
@export var key_mesh: Node3D
@export var blocker_wall: StaticBody3D # <--- NEW: The link to your invisible wall
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
	
	# --- NEW: Destroy the invisible wall immediately! ---
	if blocker_wall: 
		blocker_wall.queue_free()
	# ----------------------------------------------------
		
	if player_node:
		player_node.has_key = true
		if "can_move" in player_node: player_node.can_move = false
			
		if monster and player_node.has_node("Camera3D"):
			var cam = player_node.get_node("Camera3D")
			
			# 1. BRUTE FORCE SPIN: Manually turn the player around exactly 180 degrees
			player_node.rotate_y(deg_to_rad(180))
			
			# 2. SNAP HEAD UP: Force the camera to look straight ahead/slightly up
			cam.rotation.x = deg_to_rad(15) 
			
			# 3. Get the player's NEW forward direction facing the room
			var new_forward = -player_node.global_transform.basis.z.normalized()
			
			# 4. Spawn the monster exactly 1.5 meters in front of the player's new view
			var spawn_pos = player_node.global_position + (new_forward * 1.2)
			
			spawn_pos.y = player_node.global_position.y + 0.3 
			
			monster.global_position = spawn_pos
			
			# 5. Make the monster look perfectly at the player
			var flat_player_pos = player_node.global_position
			flat_player_pos.y = monster.global_position.y
			monster.look_at(flat_player_pos, Vector3.UP)
			
			monster.rotate_y(deg_to_rad(90)) 
			
			monster.show()
			
		if player_node.has_method("play_scream"): 
			player_node.play_scream()
			
		if player_node.has_method("apply_shake"): 
			player_node.apply_shake(0.4, 2.5) 
			
		await get_tree().create_timer(2.5).timeout
		
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
