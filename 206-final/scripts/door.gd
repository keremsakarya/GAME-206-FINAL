extends MeshInstance3D

@onready var ui_label = $CanvasLayer/Label

var is_player_near = false
var is_open = false

func _unhandled_input(event):
	if is_player_near and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed:
			toggle_door()

func toggle_door():
	var tween = create_tween()
	
	if not is_open:
		is_open = true
		tween.tween_property(self, "rotation:y", deg_to_rad(-90), 0.8)
	else:
		is_open = false
		tween.tween_property(self, "rotation:y", 0.0, 0.8)


func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		is_player_near = true
		ui_label.show()


func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_near = false
		ui_label.hide()
