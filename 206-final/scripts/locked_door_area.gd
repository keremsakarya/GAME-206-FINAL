extends Area3D

@export var door_hinge: Node3D # The node that rotates to open the door

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
	if not player_node: return
	
	# Check if the player picked up the key from the table!
	if player_node.has_key:
		is_opened = true
		if "can_move" in player_node:
			player_node.can_move = false
			
		# 1. Fade the screen to black
		black_screen.show()
		var tween_in = create_tween()
		tween_in.tween_property(black_screen, "modulate:a", 1.0, 0.5)
		await tween_in.finished
		
		# 2. Play the unlocking sound and wait 1 second
		unlock_audio.play()
		await get_tree().create_timer(1.0).timeout
		
		# 3. Physically open the door (rotates it 90 degrees)
		if door_hinge:
			door_hinge.rotation_degrees.y -= 90
			
		# 4. Fade the screen back in
		var tween_out = create_tween()
		tween_out.tween_property(black_screen, "modulate:a", 0.0, 0.5)
		await tween_out.finished
		
		black_screen.hide()
		
		if "can_move" in player_node:
			player_node.can_move = true
	else:
		# If they don't have the key yet!
		print("The door is locked.")
		# You can add a rattling sound effect here later!

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_opened:
		player_node = body
		is_player_near = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_player_near = false
