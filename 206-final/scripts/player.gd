extends CharacterBody3D

const WALK_SPEED = 3.0
const SPRINT_SPEED = 5.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002
const NORMAL_FOV = 75.0
const SPRINT_FOV = 90.0 # Increase this to 100 for a more extreme speed effect
var bob_time: float = 0.0
const BOB_FREQ = 2.0
const BOB_AMP = 0.06 # How aggressive the camera shake is
# ------------------------------------

var current_speed = WALK_SPEED
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera3D
@onready var pistol_model = $Camera3D/Pistol
@onready var pickup_ui = $PickupUI
var can_move = true
var can_exit = false
@onready var anim_player = $Camera3D/Pistol/AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pistol_model.visible = false
	pickup_ui.hide()

# ----------- Fare Kontrolü (Etrafa Bakma) ----------
func _unhandled_input(event):
	# Fareyi boşa çıkarmak için ESC
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if not can_move: return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Sağa sola bakarken player da döner
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Yukarı aşağı bakarken sadece kamera döner
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		
		# Kamera takla atmasın diye açı sınırlaması
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
		# Tuşları bırakınca tak diye durmasın
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
		if is_on_floor():
			anim_player.play("Pistol_IDLE")
	
	move_and_slide() # This is your existing code
	
	# --- SPRINT EFFECTS (FOV & HEADBOB) ---
	var target_fov = NORMAL_FOV
	
	# If we are moving, on the ground, and sprinting, trigger the speed effect
	if direction and current_speed == SPRINT_SPEED and is_on_floor():
		target_fov = SPRINT_FOV
		
	# Smoothly zoom the camera in and out for that "motion blur" speed feel
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# Camera Shake (Headbob)
	if direction and is_on_floor():
		# If sprinting, make the shake much more violent
		var shake_multiplier = 1.5 if current_speed == SPRINT_SPEED else 1.0
		bob_time += delta * BOB_FREQ * current_speed * shake_multiplier
		
		# v_offset and h_offset shake the camera lens without messing up mouse aiming!
		camera.v_offset = sin(bob_time) * BOB_AMP * shake_multiplier
		camera.h_offset = cos(bob_time * 0.5) * (BOB_AMP / 2.0) * shake_multiplier
	else:
		# Smoothly calm the camera down when the player stops moving
		bob_time = 0.0
		camera.v_offset = lerp(camera.v_offset, 0.0, delta * 5.0)
		camera.h_offset = lerp(camera.h_offset, 0.0, delta * 5.0)
	# --------------------------------------

# Silah tetiklenmesi
func show_weapon_pickup_ui():
	can_move = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Fade-in
	var fade_target = $PickupUI/FadeTarget
	fade_target.modulate.a = 0.0 # başta görünmezlik
	pickup_ui.show()
	
	# Alpha değerini 0.5 saniyede görünür yapma
	var tween = create_tween()
	tween.tween_property(fade_target, "modulate:a", 1.0, 0.5)

# Butona basılınca



func _on_button_pressed() -> void:
	pickup_ui.hide()
	pistol_model.visible = true
	can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
