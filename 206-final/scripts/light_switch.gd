extends MeshInstance3D

@export var target_lights: Array[Light3D] = []

var is_player_near = false
var is_lights_on = false

func _unhandled_input(event):
	if is_player_near and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			toggle_lights()

func toggle_lights():
	is_lights_on = not is_lights_on
	
	for light in target_lights:
		if light != null:
			light.visible = is_lights_on

func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		is_player_near = true


func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_near = false
