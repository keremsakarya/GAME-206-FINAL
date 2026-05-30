extends Area3D


@onready var ui_label = $CanvasLayer/Label
@onready var screen_darkener = $CanvasLayer/ColorRect
@onready var wash_audio = $WashAudio

var is_player_near = false
var is_washing = false
var player_node: Node3D = null


func _unhandled_input(event):
	if is_player_near and not is_washing and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			start_washing_hands()

func start_washing_hands():
	is_washing = true
	ui_label.hide()
	
	if player_node and "can_move" in player_node:
		player_node.can_move = false
	
	wash_audio.play()
	
	screen_darkener.show()
	var tween = create_tween()
	tween.tween_property(screen_darkener,"modulate:a", 1.0, 1.5)
	
	await get_tree().create_timer(22.0).timeout
	
	if player_node and "can_move" in player_node:
		player_node.can_move = true
	
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_washing:
		is_player_near = true
		player_node = body
		ui_label.show()


func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player" and not is_washing:
		is_player_near = false
		ui_label.hide()
