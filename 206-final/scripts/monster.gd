extends CharacterBody3D

@export var speed: float = 5.3

var is_chasing: bool = false
var player_node: Node3D = null

# Düğüm yollarını yeni hiyerarşiye göre güncelledik
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

	# 2. Kovalama Mantığı
	if is_chasing and player_node:
		var direction = global_position.direction_to(player_node.global_position)
		direction.y = 0 
		direction = direction.normalized()
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		# --- GÜVENLİ DÖNÜŞ SİSTEMİ ---
		# Bütün fiziksel bedeni değil, SADECE görsel modeli oyuncuya çeviriyoruz!
		if direction != Vector3.ZERO and visual_model:
			var look_target = visual_model.global_position + direction
			visual_model.look_at(look_target, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func start_chase(target_player):
	if not is_chasing:
		is_chasing = true
		player_node = target_player
		
		if anim_player:
			anim_player.play("NlaTrack_001")
			
		if idle_sound:
			idle_sound.stop()
			
		if chase_sound and not chase_sound.playing:
			chase_sound.play()
