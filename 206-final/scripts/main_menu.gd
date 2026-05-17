extends Control

@onready var logo_player = $CanvasLayer/LogoPlayer
@onready var start_button = $CanvasLayer/StartButton
@onready var controls_button = $CanvasLayer/ControlsButton
@onready var exit_button = $CanvasLayer/ExitButton

func _ready():
	if Global.intro_played == false:
		start_button.hide()
		controls_button.hide()
		exit_button.hide()
		
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		logo_player.play()
	
	else:
		if logo_player:
			logo_player.queue_free()
		
		start_button.show()
		controls_button.show()
		exit_button.show()
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_logo_player_finished() -> void:
	Global.intro_played = true
	
	logo_player.queue_free()
	start_button.show()
	controls_button.show()
	exit_button.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/metro.tscn")


func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/controls.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
