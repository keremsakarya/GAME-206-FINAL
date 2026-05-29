extends OmniLight3D

@onready var base_energy = light_energy

func _process(_delta: float) -> void:
	# A 15% chance every single frame to violently glitch the light
	if randf() < 0.30:
		# Randomly dim the light down to almost zero, or spike it slightly brighter
		light_energy = base_energy * randf_range(0.1, 1.2)
	else:
		# Snap instantly back to normal
		light_energy = base_energy
