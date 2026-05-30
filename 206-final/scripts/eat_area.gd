extends Area3D

@onready var ui_label = $"../CanvasLayer/Label"
@onready var screen_darkener = $"../CanvasLayer/ColorRect"
@onready var eat_audio = $"../EatAudio"

var is_player_near = false
var is_eating = false
var player_node: Node3D = null


func _ready():
	monitoring = false
	ui_label.hide()
	screen_darkener.hide()

func _unhandled_input(event):
	if is_player_near and not is_eating and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			start_eating()

func start_eating():
	is_eating = true
	ui_label.hide()
	
	if player_node and "can_move" in player_node:
		player_node.can_move = false
	
	eat_audio.play()
	
	screen_darkener.show()
	var tween = create_tween()
	tween.tween_property(screen_darkener, "modulate:a", 1.0, 1.5)
	
	await get_tree().create_timer(11.0).timeout
	
	if player_node:
		var hand_pos = player_node.get_node_or_null("Camera3D/HandPosition")
		if hand_pos and hand_pos.get_child_count() > 0:
			var food_node = hand_pos.get_child(0)
			food_node.queue_free()
	
	var tween_out = create_tween()
	tween_out.tween_property(screen_darkener, "modulate:a", 0.0, 1.5)
	await tween_out.finished
	
	if player_node and "can_move" in player_node:
		player_node.can_move = true
	
	if has_node("CanvasLayer"):
		$CanvasLayer.queue_free()
	elif screen_darkener:
		screen_darkener.get_parent().queue_free()
	
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_eating:
		player_node = body
		is_player_near = true
		ui_label.show()


func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player" and not is_eating:
		is_player_near = false
		ui_label.hide()
