extends CanvasLayer

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause_menu()

func toggle_pause_menu():
	var is_game_paused = not get_tree().paused
	get_tree().paused = is_game_paused
	
	visible = is_game_paused
	
	if is_game_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_continue_pressed():
	toggle_pause_menu()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
