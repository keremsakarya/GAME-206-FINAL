extends StaticBody3D

@onready var subtitle_label = $SubtitleUI/Label
var message_shown = false

func _ready():
	subtitle_label.hide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		if body.can_exit:
			queue_free()
			
		elif not message_shown:
			message_shown = true
			subtitle_label.show()
			await get_tree().create_timer(5.0).timeout
			subtitle_label.hide()
