extends CharacterBody3D

@export var speed: float = 5.2
# Haritadaki görünmez noktaları (rayları) bu listeye atacağız
@export var waypoints: Array[Node3D] 

var is_chasing: bool = false
var current_point_index: int = 0
var is_caught: bool = false

@onready var visual_model = $VisualModel
# Eğer AnimationPlayer'ın ismi veya yeri farklıysa burayı ona göre güncelle
@onready var anim_player = $VisualModel/AnimationPlayer 
@onready var audio_idle = $AudioIdle
@onready var audio_chase = $AudioChase
@onready var catch_area = $CatchArea
@onready var face_target = $FaceTarget
@onready var jumpscare_sound = $JumpscareSound

func _ready():
	# Başlangıç: Bekleme animasyonu ve bekleme sesi
	if anim_player:
		anim_player.play("NlaTrack")
	if audio_idle and not audio_idle.playing:
		audio_idle.play()

func _physics_process(delta):
	# 1. Yerçekimi
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# 2. Nokta Takip (Raylı Sistem) Mantığı
	if is_chasing and waypoints.size() > 0 and current_point_index < waypoints.size():
		var target_node = waypoints[current_point_index]
		
		if target_node:
			var target_pos = target_node.global_position
			
			# Canavarın dikey (Y) eksenini yok sayıp, sadece zemindeki X ve Z'ye odaklanıyoruz
			var flat_monster_pos = Vector3(global_position.x, 0, global_position.z)
			var flat_target_pos = Vector3(target_pos.x, 0, target_pos.z)
			
			var direction = flat_monster_pos.direction_to(flat_target_pos)
			direction = direction.normalized()
			
			# Noktaya ulaştı mı? (1.0 metre yaklaştıysa sıradaki noktaya geç)
			if flat_monster_pos.distance_to(flat_target_pos) < 1.0:
				current_point_index += 1
			else:
				# Noktaya doğru yürü
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
				
				# GÜVENLİ DÖNÜŞ SİSTEMİ (Uçma hatasını çözen atan2 matematiği)
				if direction != Vector3.ZERO:
					var target_angle = atan2(-direction.x, -direction.z)
					rotation.y = target_angle
	else:
		# Noktalar bittiyse (veya başlamadıysa) tamamen dur
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

# Tetikleyici Alan (Trigger) bu fonksiyonu çalıştıracak
func start_chase():
	if not is_chasing:
		is_chasing = true
		current_point_index = 0
		
		# Animasyonu Koşma (NlaTrack_001) olarak değiştir
		if anim_player:
			anim_player.play("NlaTrack_001")
			
		# Sesleri Değiştir
		if audio_idle:
			audio_idle.stop()
			
		if audio_chase and not audio_chase.playing:
			audio_chase.play()


func _on_catch_area_body_entered(body: Node3D) -> void:
	if body.name == "Player" and is_chasing and not is_caught:
		is_caught = true
		is_chasing = false # Stop the chasing logic
		
		# 1. FREEZE PLAYER
		body.process_mode = Node.PROCESS_MODE_DISABLED
		
		# 2. FREEZE MONSTER ANIMATION
		# Bu komut canavarın animasyonunu tam o karede dondurur
		if anim_player:
			anim_player.pause()
		
		# 3. LOCK CAMERA TO MONSTER'S FACE
		var player_camera = get_viewport().get_camera_3d()
		if player_camera:
			player_camera.look_at(face_target.global_position, Vector3.UP)
			
		# 4. MANAGE AUDIO (Jumpscare sesini başlat)
		if audio_chase:
			audio_chase.stop()
		if jumpscare_sound:
			jumpscare_sound.play()
			
		# 5. FADE-OUT SCREEN (Ses ile aynı anda başlar)
		var canvas = CanvasLayer.new()
		canvas.layer = 100 
		add_child(canvas)
		
		var dark_screen = ColorRect.new()
		dark_screen.color = Color(0, 0, 0, 0) # Transparent black
		dark_screen.set_anchors_preset(Control.PRESET_FULL_RECT) 
		canvas.add_child(dark_screen)
		
		var tween = create_tween()
		# Şeffaflığı 0'dan 1'e 2 saniye içinde çıkarır
		tween.tween_property(dark_screen, "color:a", 1.0, 2.0) 
		
		# Tween animasyonunun (ve aynı uzunluktaki sesin) bitmesini bekle
		await tween.finished
		
		# 6. RESET SCENE
		get_tree().reload_current_scene()
