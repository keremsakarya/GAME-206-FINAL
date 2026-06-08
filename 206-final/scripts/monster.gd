extends CharacterBody3D

@export var speed: float = 5.3
@export var waypoints: Array[Node3D] # Haritadaki noktaları buraya ekleyeceğiz

var is_chasing: bool = false
var current_point_index: int = 0

@onready var visual_model = $VisualModel
@onready var anim_player = $VisualModel/AnimationPlayer 
@onready var idle_sound = $IdleSound
@onready var chase_sound = $ChaseSound

func _ready():
	if anim_player:
		anim_player.play("NlaTrack")
	if idle_sound and not idle_sound.playing:
		idle_sound.play()

func _physics_process(delta):
	# 1. Yerçekimi
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# 2. Nokta (Waypoint) Takip Mantığı
	if is_chasing and waypoints.size() > 0 and current_point_index < waypoints.size():
		var target_pos = waypoints[current_point_index].global_position
		
		# Sadece X ve Z eksenindeki mesafeye bakıyoruz (Yüksekliği yoksay)
		var flat_target = Vector3(target_pos.x, global_position.y, target_pos.z)
		var direction = global_position.direction_to(flat_target)
		
		# Noktaya ulaştı mı? (1 metre yaklaştıysa sıradaki noktaya geç)
		if global_position.distance_to(flat_target) < 1.0:
			current_point_index += 1
		else:
			# Noktaya doğru yürü
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
			# Noktaya doğru yüzünü güvenli şekilde dön
			if direction != Vector3.ZERO:
				var target_angle = atan2(-direction.x, -direction.z)
				rotation.y = target_angle
	else:
		# Noktalar bittiyse (veya başlamadıysa) tamamen dur
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

# Trigger artık oyuncuyu (target_player) istemiyor, sadece koşuyu başlatıyor
func start_chase():
	if not is_chasing:
		is_chasing = true
		current_point_index = 0
		
		if anim_player:
			anim_player.play("NlaTrack_001")
			
		if idle_sound:
			idle_sound.stop()
			
		if chase_sound and not chase_sound.playing:
			chase_sound.play()
