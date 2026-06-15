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
var has_key: bool = false

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

# --- WEAPON & HUD VARIABLES ---
@onready var aim_ray = $Camera3D/AimRay 
@onready var gunshot_audio = $GunshotAudio
@onready var reticle = $HUD/CenterContainer/Reticle 
var is_shooting: bool = false
var gun_damage: int = 35
@export var start_armed: bool = false
# ------------------------------

# --- AUDIO VARIABLES ---
@onready var footstep_audio = $FootstepAudio
@onready var landing_audio = $LandingAudio 

@onready var grass_landing = $GrassLanding
@onready var carpet_landing = $CarpetLanding
@onready var sidewalk_landing = $SidewalkLanding
@onready var mine_landing = $MineLanding

@onready var grass_audio = $GrassAudio 
@onready var carpet_audio = $CarpetAudio 
@onready var sidewalk_audio = $SidewalkAudio 
@onready var mine_footstep_audio = $MineFootstepAudio
@onready var floor_detector = $FloorDetector
var step_timer: float = 0.0

# --- JUMPSCARE VARIABLES ---
@onready var scream_audio = $ScreamAudio
@onready var heartbeat_audio = $HeartbeatAudio
@onready var breath_audio = $BreathAudio

var shake_intensity: float = 0.0
var shake_duration: float = 0.0

func _ready() -> void:
	add_to_group("Player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pickup_ui.hide()
	
	# If this level says we start with a gun, turn everything on!
	if start_armed:
		pistol_model.show()
		$HUD.show() # Make sure the main UI layer is on
		if reticle: reticle.show()
	else:
		pistol_model.hide()
		if reticle: reticle.hide()
			
	camera_base_y = camera.position.y

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	# --- LEFT CLICK TO SHOOT ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if pistol_model.visible and can_move and not is_shooting:
				
				# Check if the player is actively moving AND holding sprint
				var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
				var is_moving = input_dir != Vector2.ZERO
				var is_sprinting = Input.is_action_pressed("sprint") and is_moving and is_on_floor()
				
				# Only shoot if they are NOT sprinting
				if not is_sprinting:
					shoot()
	# ---------------------------
	
	if not can_move: return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if shake_duration > 0:
		shake_duration -= delta
		camera.h_offset = randf_range(-shake_intensity, shake_intensity)
		camera.v_offset = randf_range(-shake_intensity, shake_intensity)
	
	if not can_move: return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINT_SPEED
	else:
		current_speed = WALK_SPEED
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if is_on_floor() and not is_shooting:
			if current_speed == SPRINT_SPEED:
				anim_player.play("Pistol_RUN")
			else:
				anim_player.play("Pistol_WALK")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
		if is_on_floor() and not is_shooting:
			anim_player.play("Pistol_IDLE")
	
	var was_in_air = not is_on_floor()
	move_and_slide() 
	
	if was_in_air and is_on_floor():
		if floor_detector.is_colliding():
			var ground = floor_detector.get_collider()
			
			if ground.is_in_group("House"):
				landing_audio.pitch_scale = randf_range(0.9, 1.1)
				landing_audio.volume_db = -8.0 
				landing_audio.play() 
			elif ground.is_in_group("Grass"):
				grass_landing.pitch_scale = randf_range(0.6, 0.7)
				grass_landing.play()
			elif ground.is_in_group("Carpet"):
				carpet_landing.pitch_scale = randf_range(0.6, 0.7)
				carpet_landing.play()
			elif ground.is_in_group("Sidewalk"):
				sidewalk_landing.pitch_scale = randf_range(0.8, 0.9)
				sidewalk_landing.play()
			elif ground.is_in_group("MineFloor"):
				mine_landing.pitch_scale = randf_range(0.8, 1.0)
				mine_landing.play()
				
			if dip_tween and dip_tween.is_valid():
				dip_tween.kill() 
			
			dip_tween = create_tween()
			dip_tween.tween_property(camera, "position:y", camera_base_y - 0.2, 0.1).set_trans(Tween.TRANS_SINE)
			dip_tween.tween_property(camera, "position:y", camera_base_y, 0.25).set_trans(Tween.TRANS_SINE)
	
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
	
	if direction and is_on_floor():
		step_timer -= delta
		
		if current_speed == SPRINT_SPEED and step_timer > 0.3:
			step_timer = 0.3
			
		if step_timer <= 0:
			if floor_detector.is_colliding():
				var ground = floor_detector.get_collider()
				
				var current_pitch = 1.0
				if current_speed == SPRINT_SPEED:
					current_pitch = randf_range(0.95, 1.15) 
				else:
					current_pitch = randf_range(0.85, 0.95) 
				
				if ground.is_in_group("House"):
					footstep_audio.pitch_scale = current_pitch
					footstep_audio.play()
				elif ground.is_in_group("Grass"):
					grass_audio.pitch_scale = current_pitch
					grass_audio.play()
				elif ground.is_in_group("Carpet"):
					carpet_audio.pitch_scale = current_pitch
					carpet_audio.play()
				elif ground.is_in_group("Sidewalk"):
					sidewalk_audio.pitch_scale = current_pitch
					sidewalk_audio.play()
				elif ground.is_in_group("MineFloor"):
					mine_footstep_audio.pitch_scale = current_pitch
					mine_footstep_audio.play()
			
			if current_speed == SPRINT_SPEED:
				step_timer = 0.3 
			else:
				step_timer = 0.6 
	else:
		step_timer = 0.0
		footstep_audio.stop()
		grass_audio.stop()
		carpet_audio.stop()
		sidewalk_audio.stop()
		mine_footstep_audio.stop() 

func shoot():
	is_shooting = true
	anim_player.play("Pistol_FIRE")
	
	if gunshot_audio:
		gunshot_audio.pitch_scale = randf_range(0.95, 1.05)
		gunshot_audio.play()
	
	if aim_ray.is_colliding():
		var target = aim_ray.get_collider()
		
		if target.is_in_group("Monster"):
			if target.has_method("take_damage"):
				target.take_damage(gun_damage)
				
	await anim_player.animation_finished
	is_shooting = false

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
	
	if reticle:
		reticle.show()

func apply_shake(intensity: float = 0.5, duration: float = 1.0) -> void:
	shake_intensity = intensity
	shake_duration = duration
	
	if duration <= 0.0:
		if camera:
			camera.h_offset = 0.0
			camera.v_offset = 0.0

func play_scream() -> void:
	if scream_audio:
		scream_audio.play()

func play_panic_audio() -> void:
	if heartbeat_audio:
		heartbeat_audio.play()
	if breath_audio:
		breath_audio.play()

func force_look_at(target_pos: Vector3) -> void:
	var flat_target = target_pos
	flat_target.y = global_position.y 
	look_at(flat_target, Vector3.UP)
	
	var height_diff = target_pos.y - camera.global_position.y
	var distance = global_position.distance_to(flat_target)
	camera.rotation.x = atan2(height_diff, distance)
