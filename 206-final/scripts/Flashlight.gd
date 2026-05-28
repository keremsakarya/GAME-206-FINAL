extends Node

@onready var flashlight: SpotLight3D = $"../Camera3D/SpotLight3D"
@onready var player: CharacterBody3D = $".."

# We will save the original ROTATION instead of position
var original_rot: Vector3
var bob_time: float = 0.0

var base_frequency: float = 2.0

# This is now in radians. 0.03 is about 1.7 degrees of wrist-twist.
var shake_amplitude: float = 0.06 

func _ready():
	flashlight.visible = false
	# Save the exact starting rotation
	original_rot = flashlight.rotation

func _unhandled_input(event):
	if event.is_action_pressed("toggle_flashlight"):
		flashlight.visible = !flashlight.visible

func _process(delta):
	var speed = player.velocity.length()
	
	if speed > 0.5 and player.is_on_floor():
		var current_freq = base_frequency
		if player.current_speed == player.SPRINT_SPEED:
			current_freq *= 1.5 
			
		bob_time += delta * current_freq * speed
		
		# Calculate the rotational twist
		var offset_x = sin(bob_time) * shake_amplitude
		var offset_y = cos(bob_time * 0.5) * (shake_amplitude / 2.0)
		
		# Apply the shake to the rotation (Pitch and Yaw)
		flashlight.rotation.x = original_rot.x + offset_x
		flashlight.rotation.y = original_rot.y + offset_y
		
	else:
		bob_time = 0.0
		# Smoothly snap the wrist back to the center when stopping
		flashlight.rotation.x = lerp(flashlight.rotation.x, original_rot.x, delta * 5.0)
		flashlight.rotation.y = lerp(flashlight.rotation.y, original_rot.y, delta * 5.0)
