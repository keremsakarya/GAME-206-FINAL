extends Area3D


@onready var fade_ui = $FadeUI
@onready var fade_rect = $FadeUI/FadeRect


func _ready() -> void:
	fade_ui.hide()

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		body.can_move = false
		
		fade_rect.modulate.a = 0.0
		fade_ui.show()
		
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
		
		await tween.finished
		
		await get_tree().create_timer(2.0).timeout
		
		get_tree().change_scene_to_file("res://scenes/bus.tscn")
