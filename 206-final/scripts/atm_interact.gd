extends Area3D

@onready var prompt_label = $UI/PromptLabel
@onready var black_bg = $UI/BlackBackground
@onready var video_player = $UI/VideoPlayer
@onready var continue_button = $UI/ContinueButton

var is_player_inside = false
var player_ref = null


func _ready():
	prompt_label.hide()
	black_bg.hide()
	video_player.hide()
	continue_button.hide()


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		is_player_inside = true
		player_ref = body
		prompt_label.show()



func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_inside = false
		player_ref = null
		prompt_label.hide()

func _input(event):
	if is_player_inside and event.is_action_pressed("interact") and not video_player.visible:
		start_video_sequence()

func start_video_sequence():
	prompt_label.hide()
	
	if player_ref:
		player_ref.can_move = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	black_bg.show()
	video_player.show()
	video_player.play()

func _on_video_stream_player_finished() -> void:
	continue_button.show()



func _on_continue_button_pressed() -> void:
	if player_ref:
		player_ref.can_move = true
		player_ref.can_exit = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	queue_free()
