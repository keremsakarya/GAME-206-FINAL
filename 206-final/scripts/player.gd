extends CharacterBody3D

const WALK_SPEED = 3.0
const SPRINT_SPEED = 5.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002
# --- CAMERA SHAKE & FOV VARIABLES ---
const NORMAL_FOV = 75.0
const SPRINT_FOV = 90.0 
var bob_time: float = 0.0
const BOB_FREQ = 2.0
const BOB_AMP = 0.06 

var camera_base_y: float = 0.0
var dip_tween: Tween
# ------------------------------------

var current_speed = WALK_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var pistol_model = $Camera3D/Pistol
@onready var pickup_ui = $PickupUI
var can_move = true
var can_exit = false
@onready var anim_player = $Camera3D/Pistol/AnimationPlayer

# --- AUDIO VARIABLES ---
@onready var footstep_audio = $FootstepAudio
@onready var landing_audio = $LandingAudio 
@onready var grass_audio = $GrassAudio # <-- Added this back for you!
@onready var floor_detector = $FloorDetector
var step_timer: float = 0.0
# -----------------------

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pistol_model.visible = false
	pickup_ui.hide()
	
	camera_base_y = camera.position.y

# ----------- Fare Kontrolü (Etrafa Bakma) ----------
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if not can_move: return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

# ----------- Fizik - Hareket -----------
func _physics_process(delta):
	if not can_move: return
	
	# Yerçekimi
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Zıplama
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Sprint
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED
	else:
		current_speed = WALK_SPEED
	
	# Kameranın baktığı yöne göre yön hesaplama
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if is_on_floor():
			if current_speed == SPRINT_SPEED:
				anim_player.play("Pistol_RUN")
			else:
				anim_player.play("Pistol_WALK")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
		if is_on_floor():
			anim_player.play("Pistol_IDLE")
	
	# --------------------------------------
	# 1. Check if we are in the air BEFORE we move
	var was_in_air = not is_on_floor()
	
	move_and_slide() # This is your existing code
	
	# 2. Check if we hit the ground AFTER we move
	if was_in_air and is_on_floor():
		if floor_detector.is_colliding():
			var ground = floor_detector.get_collider()
			
			if ground.is_in_group("House"):
				landing_audio.pitch_scale = randf_range(0.9, 1.1)
				landing_audio.volume_db = -8.0 
				landing_audio.play(0.79) 
			elif ground.is_in_group("Grass"):
				# Soft dirt landing!
				grass_audio.pitch_scale = randf_range(0.6, 0.7)
				grass_audio.play()
				
			# --- CAMERA DIP TWEEN (Happens on all floors) ---
			if dip_tween and dip_tween.is_valid():
				dip_tween.kill() 
			
			dip_tween = create_tween()
			dip_tween.tween_property(camera, "position:y", camera_base_y - 0.2, 0.1).set_trans(Tween.TRANS_SINE)
			dip_tween.tween_property(camera, "position:y", camera_base_y, 0.25).set_trans(Tween.TRANS_SINE)
			# ------------------------
	# --------------------------------------
	
	# --- SPRINT EFFECTS (FOV & HEADBOB) ---
	var target_fov = NORMAL_FOV
	
	if direction and current_speed == SPRINT_SPEED and is_on_floor():
		target_fov = SPRINT_FOV
		
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	if direction and is_on_floor():
		var shake_multiplier = 1.5 if current_speed == SPRINT_SPEED else 1.0
		bob_time += delta * BOB_FREQ * current_speed * shake_multiplier
		
		camera.v_offset = sin(bob_time) * BOB_AMP * shake_multiplier
		camera.h_offset = cos(bob_time * 0.5) * (BOB_AMP / 2.0) * shake_multiplier
	else:
		bob_time = 0.0
		camera.v_offset = lerp(camera.v_offset, 0.0, delta * 5.0)
		camera.h_offset = lerp(camera.h_offset, 0.0, delta * 5.0)
	
	# --------------------------------------
	# --- FOOTSTEP AUDIO ---
	if direction and is_on_floor():
		step_timer -= delta
		if step_timer <= 0:
			if floor_detector.is_colliding():
				var ground = floor_detector.get_collider()
				
				if ground.is_in_group("House"):
					footstep_audio.pitch_scale = randf_range(0.85, 1.15)
					footstep_audio.play()
				elif ground.is_in_group("Grass"):
					grass_audio.pitch_scale = randf_range(0.85, 1.15)
					grass_audio.play()
				else:
					print("WARNING: This floor does NOT have a tag! Its current groups are: ", ground.get_groups())
			
			if current_speed == SPRINT_SPEED:
				step_timer = 0.3 
			else:
				step_timer = 0.6 
	else:
		step_timer = 0.0
	# ----------------------
	
# Silah tetiklenmesi
func show_weapon_pickup_ui():
	can_move = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var fade_target = $PickupUI/FadeTarget
	fade_target.modulate.a = 0.0 
	pickup_ui.show()
	
	var tween = create_tween()
	tween.tween_property(fade_target, "modulate:a", 1.0, 0.5)

func _on_button_pressed() -> void:
	pickup_ui.hide()
	pistol_model.visible = true
	can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
