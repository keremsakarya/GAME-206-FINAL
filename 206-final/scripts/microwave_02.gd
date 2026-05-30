extends MeshInstance3D

@export var eat_area: Area3D

@onready var ui_label = $CanvasLayer/Label
@onready var microwave_audio = $MicrowaveAudio

# Mikrodalga durumları
enum State {READY_TO_COOK, COOKING, READY_TO_PICK_UP, DONE}
var current_state = State.READY_TO_COOK

var is_player_near = false
var player_node: Node3D = null
var food_node: Node3D = null

func _ready():
	ui_label.hide()

func _unhandled_input(event):
	if is_player_near and event is InputEventKey:
		if event.keycode == KEY_G and event.pressed and not event.is_echo():
			match current_state:
				State.READY_TO_COOK:
					if check_player_has_food():
						start_cooking()
						
				State.READY_TO_PICK_UP:
					pickup_food()

# Oyuncunun elinde yemek var mı
func check_player_has_food() -> bool:
	if player_node:
		var hand_pos = player_node.get_node_or_null("Camera3D/HandPosition")
		if hand_pos and hand_pos.get_child_count() > 0:
			food_node = hand_pos.get_child(0)
			return true
	
	return false

# Yemeği mikrodalgaya koymak
func start_cooking():
	current_state = State.COOKING
	ui_label.hide()
	
	if food_node:
		food_node.hide()
	
	microwave_audio.play()
	
	await get_tree().create_timer(20.0).timeout
	
	microwave_audio.stop()
	current_state = State.READY_TO_PICK_UP
	
	if is_player_near:
		ui_label.text = "[G] to grab your meal"
		ui_label.show()

# Yemeği geri almak
func pickup_food():
	current_state = State.DONE
	ui_label.hide()
	
	if food_node:
		food_node.show()
	
	if eat_area:
		eat_area.monitoring = true



func _on_microwave_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_node = body
		is_player_near = true
		
		if current_state == State.READY_TO_COOK:
			if check_player_has_food():
				ui_label.text = "[G] to use microwave"
				ui_label.show()
			elif current_state == State.READY_TO_PICK_UP:
				ui_label.text = "[G] to grab your meal"
				ui_label.show()


func _on_microwave_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_near = false
		ui_label.hide()
