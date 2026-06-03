extends Area3D

@export_multiline var string: String = "Buraya altyazı yazılacak..."
@export var screen_time: float = 3.0

@onready var ui_label = $CanvasLayer/Label

var has_triggered = false

func _ready():
	ui_label.hide()
	ui_label.text = string

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not has_triggered:
		has_triggered = true
		
		ui_label.show()
		
		await  get_tree().create_timer(screen_time).timeout
		
		ui_label.hide()
		queue_free()
