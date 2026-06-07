extends Area3D

@export_file("*.tscn") var next_scene_path: String

# Exported nodes so you can plug them directly into the Inspector
@export var color_rect: ColorRect
@export var interact_label: Label
@export var audio_player: AudioStreamPlayer

var is_player_near = false
var is_transitioning = false
var original_prompt_text: String = ""

func _ready():
	# Save whatever text you typed into the Inspector label originally
	if interact_label:
		original_prompt_text = interact_label.text
		interact_label.hide()
		
	# Hide the black screen when the game starts
	if color_rect:
		color_rect.color.a = 0.0 
		color_rect.hide()

func _unhandled_input(event):
	# Listen for the 'E' key when the player is close
	if is_player_near and not is_transitioning and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			
			# THE LOCK: Check if the player is allowed to exit yet!
			var player = get_tree().get_first_node_in_group("Player")
			if player and "can_exit" in player:
				if player.can_exit:
					start_transition()
				else:
					print("Player tried to enter, but the mine door is locked until the attic is cleared!")

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
	await get_tree().create_timer(5.0).timeout
	
	# 5. Teleport the player / Load the mine scene
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("ERROR: No scene path assigned in the Inspector!")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_transitioning:
		is_player_near = true
		
		if interact_label:
			# Change the UI text depending on if it's locked or unlocked!
			if "can_exit" in body and body.can_exit:
				interact_label.text = original_prompt_text
			else:
				# What it displays if they haven't done the attic yet
				interact_label.text = "The mine door is tightly locked from the inside."
			
			interact_label.show()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_player_near = false
		if interact_label: 
			interact_label.hide()
