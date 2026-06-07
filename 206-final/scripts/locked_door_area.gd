extends Area3D

@export var door_hinge: Node3D 
@onready var unlock_audio = $UnlockAudio
@onready var black_screen = $CanvasLayer/ColorRect

var is_player_near = false
var is_opened = false
var player_node: Node3D = null

func _ready():
	black_screen.modulate.a = 0.0
	black_screen.hide()

func _unhandled_input(event):
	if is_player_near and not is_opened and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			try_open_door()

func try_open_door():
	if not player_node or not player_node.has_key: return
	
	is_opened = true
	
	# --- THE MAGIC GLOBAL UNLOCK ---
	# The exact second the player uses the key, the Mine Door is globally unlocked!
	if "can_exit" in player_node: 
		player_node.can_exit = true
	# -------------------------------
	
	if "can_move" in player_node: player_node.can_move = false
			
	black_screen.show()
	var tween_in = create_tween()
	tween_in.tween_property(black_screen, "modulate:a", 1.0, 0.5)
	await tween_in.finished
		
	unlock_audio.play()
	await unlock_audio.finished
		
	if door_hinge:
		door_hinge.rotation_degrees.y -= 90
			
	var tween_out = create_tween()
	tween_out.tween_property(black_screen, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	black_screen.hide()
		
	# VANISH THE DOOR: Removes the entire door and hinge from the scene
	door_hinge.queue_free() 
		
	if "can_move" in player_node: player_node.can_move = true

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_opened:
		player_node = body
		is_player_near = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_player_near = false
