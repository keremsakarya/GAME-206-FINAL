extends CharacterBody3D

@export var speed: float = 5.3
# Haritadaki görünmez noktaları (rayları) bu listeye atacağız
@export var waypoints: Array[Node3D] 

var is_chasing: bool = false
var current_point_index: int = 0

@onready var visual_model = $VisualModel
# Eğer AnimationPlayer'ın ismi veya yeri farklıysa burayı ona göre güncelle
@onready var anim_player = $VisualModel/AnimationPlayer 
@onready var audio_idle = $AudioIdle
@onready var audio_chase = $AudioChase

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
