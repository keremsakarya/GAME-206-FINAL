extends Area3D

@export var monster: Node3D
@export var key_mesh: Node3D

var is_player_near = false
var triggered = false
var player_node: Node3D = null

func _ready():
	# Hide the 3D monster at the start
	if monster:
		monster.hide()

func _unhandled_input(event):
	if is_player_near and not triggered and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			trigger_jumpscare()

func trigger_jumpscare():
	triggered = true
	
	if key_mesh:
		key_mesh.hide() # The key disappears from the table!
		
	if player_node:
		# Give the player the key so the Attic Door script will allow them in!
		player_node.has_key = true 
		
		# Freeze the player
		if "can_move" in player_node:
			player_node.can_move = false
			
		# 1. Reveal the 3D monster on the wall
		if monster:
			monster.show()
			
		# 2. Force the camera to instantly snap to look at the monster
		if monster and player_node.has_method("force_look_at"):
			player_node.force_look_at(monster.global_position)
			
		# 3. Play the scream and shake the camera
		if player_node.has_method("play_scream"):
			player_node.play_scream()
			
		if player_node.has_method("apply_shake"):
			player_node.apply_shake(1.0, 1.5) # Intense shake for 1.5 seconds
			
		# 4. Hold the scare (staring at the 3D monster) for 1.5 seconds
		await get_tree().create_timer(1.5).timeout
		
		# 5. The monster vanishes!
		if monster:
			monster.hide() 
		
		if player_node.has_method("apply_shake"):
			player_node.apply_shake(0.0, 0.0)
			
		if player_node.has_method("play_panic_audio"):
			player_node.play_panic_audio()
			
		# Wait 2 seconds in the dark, breathing heavy
		await get_tree().create_timer(2.0).timeout
		
		# Unfreeze the player so they can run to the attic!
		if "can_move" in player_node:
			player_node.can_move = true
			
		queue_free() # Delete the trigger so it doesn't happen again

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not triggered:
		player_node = body
		is_player_near = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_player_near = false
		player_node = null
