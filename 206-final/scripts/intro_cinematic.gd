extends CanvasLayer


@onready var intro_video = $IntroVideo
@onready var continue_button = $ContinueButton

@onready var player = $"../Player"

func _ready():
	continue_button.hide()
	
	if player:
		player.can_move = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	intro_video.play()

func _on_intro_video_finished() -> void:
	continue_button.show()


func _on_continue_button_pressed() -> void:
	#if player:
		#player.can_move = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	queue_free()
