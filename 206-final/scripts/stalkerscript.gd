extends Node3D

var player_camera: Camera3D 

@onready var jumpscare_ui = $JumpscareLayer
@onready var scare_face = $JumpscareLayer/ScareFace # <--- Grabs the actual image

var has_triggered = false
var is_active = false

func _ready() -> void:
	add_to_group("Stalker")
	hide() 
	jumpscare_ui.hide() 
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player_camera = player.get_node("Camera3D")

func activate() -> void:
	is_active = true
	show() 

func _process(delta: float) -> void:
	if not is_active or has_triggered or not player_camera:
		return
		
	var dir_to_stalker = (global_position - player_camera.global_position).normalized()
	var camera_forward = -player_camera.global_transform.basis.z.normalized()
	
	var sight_angle = camera_forward.dot(dir_to_stalker)
	
	if sight_angle > 0.95:
		_trigger_jumpscare()

func _trigger_jumpscare() -> void:
	has_triggered = true
	var player = player_camera.get_parent() 
	
	# Freeze the player
	if "can_move" in player:
		player.can_move = false
		
	# Tension pause
	await get_tree().create_timer(0.5).timeout
	
	if player.has_method("play_scream"):
		player.play_scream()
		
	hide() 
	jumpscare_ui.show() 
	
	# ==========================================
	# --- THE JUMPSCARE ANIMATION UPGRADE ---
	# ==========================================
	
	# 1. Center the pivot point so it zooms exactly from the middle of the screen
	scare_face.pivot_offset = scare_face.size / 2.0
	scare_face.scale = Vector2(1.0, 1.0)
	
	# 2. THE LUNGE: Violently scale the image up over 1 second
	var zoom_tween = create_tween()
	zoom_tween.tween_property(scare_face, "scale", Vector2(1.15, 1.15), 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	# 3. THE GLITCH: Rapidly flicker the transparency (opacity) 20 times a second
	var flicker_tween = create_tween().set_loops()
	flicker_tween.tween_property(scare_face, "modulate:a", 0.5, 0.05)
	flicker_tween.tween_property(scare_face, "modulate:a", 1.0, 0.05)
	
	# ==========================================
	
	# Keep your violent camera shake in the background
	if player.has_method("apply_shake"):
		player.apply_shake()
		
	# Hold the nightmare on screen for 1 second
	await get_tree().create_timer(1.0).timeout
	
	# Kill the animations before hiding the face
	if zoom_tween: zoom_tween.kill()
	if flicker_tween: flicker_tween.kill()
	
	# Vanish the face and kill the camera shake
	jumpscare_ui.hide()
	
	if player.has_method("apply_shake"):
		player.apply_shake(0.0, 0.0) 
	
	if player.has_method("play_panic_audio"):
		player.play_panic_audio()
		
	# Wait 3 seconds in the dark
	await get_tree().create_timer(3.0).timeout
	
	# Unfreeze the player and delete the stalker entirely
	if "can_move" in player:
		player.can_move = true
		
	queue_free()
