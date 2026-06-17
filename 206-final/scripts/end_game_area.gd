extends Area3D

@onready var end_canvas = $EndCanvas
@onready var dark_screen = $EndCanvas/ColorRect

# VBox yerine doğrudan Label ve Button'ı koda dahil ediyoruz
@onready var label = $EndCanvas/Label
# NOT: Eğer ağaçtaki butonun adı 'BtnMenu' ise aşağıdaki yolu $EndCanvas/BtnMenu yap
@onready var btn_menu = $EndCanvas/Button 

func _ready():
	end_canvas.hide()
	dark_screen.color.a = 0.0 
	
	# Hide the label and button at the start
	label.hide() 
	btn_menu.hide()
	
	btn_menu.pressed.connect(_on_menu_pressed)
	monitoring = false

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		get_tree().paused = true
		
		# Show the canvas layer (screen is still transparent)
		end_canvas.show()
		
		var tween = create_tween()
		tween.tween_property(dark_screen, "color:a", 1.0, 4.0)
		
		# Wait for the 4-second fade-out animation to finish completely
		await tween.finished
		
		# Show the text and button, and release the mouse AFTER the screen is black
		label.show()
		btn_menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_menu_pressed():
	get_tree().paused = false
	Global.skip_video = true
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
