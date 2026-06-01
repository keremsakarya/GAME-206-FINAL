extends Area3D

var stalker: Node3D 

@onready var ui_label = $CanvasLayer/Label
@onready var screen_darkener = $CanvasLayer/ColorRect
@onready var sleep_audio = $"../SleepAudio"
@onready var wake_audio = $"../GlassAudio"

var is_player_near = false
var is_sleeping = false
var player_node: Node3D = null

func _ready():
	ui_label.hide()
	screen_darkener.hide()
	screen_darkener.modulate.a = 0.0
	
	# --- AUTO-FIND THE STALKER ---
	# We use call_deferred to make sure the Stalker has finished loading into the scene first
	call_deferred("_find_stalker")

func _find_stalker():
	stalker = get_tree().get_first_node_in_group("Stalker")

func _unhandled_input(event):
	if is_player_near and not is_sleeping and event is InputEventKey:
		if event.keycode == KEY_E and event.pressed and not event.is_echo():
			start_sleeping()

func start_sleeping():
	is_sleeping = true
	ui_label.hide()
	
	if player_node and "can_move" in player_node:
		player_node.can_move = false
	
	screen_darkener.show()
	var tween_in = create_tween()
	tween_in.tween_property(screen_darkener, "modulate:a", 1.0, 1.5)
	
	sleep_audio.play()
	
	await get_tree().create_timer(10.0).timeout
	
	sleep_audio.stop()
	wake_audio.play()
	
	await wake_audio.finished
	
	var tween_out = create_tween()
	tween_out.tween_property(screen_darkener, "modulate:a", 0.0, 1.5)
	await tween_out.finished
	
	if player_node and "can_move" in player_node:
		player_node.can_move = true
		
	# --- THE STALKER APPEARS ---
	if stalker:
		stalker.activate()
	
	# Gizli objeler görünür oluyor
	var hidden_object = get_tree().get_nodes_in_group("HiddenObjectsBeforeJumpscare")
	
	for obj in hidden_object:
		if obj:
			obj.process_mode = Node.PROCESS_MODE_INHERIT
			
			if not obj is Area3D:
				obj.show()
	
	queue_free()
	
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_sleeping:
		player_node = body
		is_player_near = true
		ui_label.show()

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player" and not is_sleeping:
		is_player_near = false
		ui_label.hide()
