extends Area3D

@export_file("*.tscn") var next_scene_path: String

# Exported nodes so you can plug them directly into the Inspector
@export var color_rect: ColorRect
@export var interact_label: Label
@export var audio_player: AudioStreamPlayer

var is_player_near = false
var is_transitioning = false

func _ready():
	# Hide the black screen and text when the game starts
	if color_rect:
		color_rect.color.a = 0.0 
		color_rect.hide()
	if interact_label:
		interact_label.hide()

func _unhandled_input(event):
	# Listen for the 'E' key when the player is close
	if is_player_near and not is_transitioning and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			start_transition()

func start_transition():
	is_transitioning = true
	
	if interact_label:
		interact_label.hide()
		
	# 1. Freeze the player so they don't walk away
	var player = get_tree().get_first_node_in_group("Player")
	if player and "can_move" in player:
		player.can_move = false
		
	# 2. Play the elevator sound directly from your node
	if audio_player:
		audio_player.play()
		
	# 3. Fade the screen to pure black over 1 second
	if color_rect:
		color_rect.show()
		var tween = create_tween()
		tween.tween_property(color_rect, "color:a", 1.0, 1.0) 
		
	# 4. Wait in the dark while the elevator audio plays
	# NOTE: Change this 5.0 to perfectly match the length of your sound file!
	await get_tree().create_timer(5.0).timeout
	
	# 5. Teleport the player / Load the mine scene
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("ERROR: No scene path assigned in the Inspector!")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_transitioning:
		is_player_near = true
		if interact_label: interact_label.show()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_player_near = false
		if interact_label: interact_label.hide()
