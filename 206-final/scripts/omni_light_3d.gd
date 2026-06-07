extends OmniLight3D


@export var min_energy = 0.5
@export var max_energy = 2.0 
@export var flicker_speed = 0.1

var time_passed = 0.0

func _process(delta):
	time_passed += delta
	
	if time_passed >= flicker_speed:
		light_energy = randf_range(min_energy, max_energy)
		
		time_passed = 0.0
