extends CharacterBody3D

@export var speed: float = 2.0
@export var patrol_distance: float = 5.0

var start_position: Vector3
var target_position: Vector3
var is_chasing_player: bool = false
var player_node: Node3D = null

@onready var audio_player = $AudioStreamPlayer3D

func _ready():
	start_position = global_position
	target_position = start_position + Vector3(patrol_distance, 0, 0)
	
	if audio_player and not audio_player.playing:
		audio_player.play()

func _physics_process(delta):
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
