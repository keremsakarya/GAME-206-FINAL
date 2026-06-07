extends CharacterBody3D

@export var speed: float = 2.0
@export var patrol_distance: float = 5.0
@export var max_hp: int = 100 # NEW: The bug's starting health

var current_hp: int # NEW: Tracks health during gameplay
var is_dead: bool = false # NEW: Stops the bug from moving when killed

var start_position: Vector3
var target_position: Vector3
var is_chasing_player: bool = false
var player_node: Node3D = null

@onready var audio_player = $AudioStreamPlayer3D

func _ready():
	# IMPORTANT: This automatically connects the bug to the player's laser!
	add_to_group("Monster") 
	current_hp = max_hp # Initialize health
	
	start_position = global_position
	target_position = start_position + Vector3(patrol_distance, 0, 0)
	
	if audio_player and not audio_player.playing:
		audio_player.play()

func _physics_process(delta):
	if is_dead: return # NEW: If the bug is dead, stop running the physics code!
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	var move_target = target_position
	
	if is_chasing_player and player_node:
		move_target = player_node.global_position
	
	var direction = global_position.direction_to(move_target)
	direction.y = 0 
	direction = direction.normalized()
	
	if not is_chasing_player:
		if global_position.distance_to(target_position) < 0.5:
			if target_position == start_position:
				target_position = start_position + Vector3(patrol_distance, 0, 0)
			else:
				target_position = start_position
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func _on_see_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		is_chasing_player = true
		player_node = body

func _on_see_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_chasing_player = false
		player_node = null
		target_position = start_position

# --- NEW: HEALTH AND DAMAGE SYSTEM ---
func take_damage(amount: int) -> void:
	if is_dead: return # Don't take damage if it is already dead
	
	current_hp -= amount
	print("Bug hit! Took ", amount, " damage. HP left: ", current_hp)
	
	if current_hp <= 0:
		die()

func die() -> void:
	is_dead = true
	print("Bug killed!")
	
	# Stop the crawling sound so a dead bug doesn't make noise
	if audio_player:
		audio_player.stop()
		
	# ----------------------------------------------------
	# TODO NEXT: Add Fallout 4 Green Blood Explosion here
	# TODO NEXT: Hide alive mesh, Show dead corpse mesh here
	# ----------------------------------------------------
	
	# For right now, we will just delete the bug so you can test if the gun works!
	queue_free()
# -------------------------------------
