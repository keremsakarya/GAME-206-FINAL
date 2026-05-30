extends MeshInstance3D


@onready var ui_label = $FoodInteractArea/CanvasLayer/Label
@onready var interact_area = $FoodInteractArea

var is_player_near = false
var is_grabbed = false
var player_node: Node3D = null


func _unhandled_input(event):
	if is_player_near and not is_grabbed and event is InputEventKey:
		if event.keycode == KEY_G and event.pressed and not event.is_echo():
			grab_food()

func grab_food():
	is_grabbed = true
	ui_label.hide()
	interact_area.monitoring = false
	
	var hand_pos = player_node.get_node("Camera3D/HandPosition")
	
	if hand_pos:
		reparent(hand_pos, false)
		position = Vector3.ZERO
		rotation = Vector3.ZERO



func _on_food_interact_area_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_grabbed:
		is_player_near = true
		player_node = body
		ui_label.show()


func _on_food_interact_area_body_exited(body: Node3D) -> void:
	if body.name == "Player" and not is_grabbed:
		is_player_near = false
		ui_label.hide()
