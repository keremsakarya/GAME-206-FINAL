extends Area3D


@export var monster_trigger_area: Area3D
@export var key_visual: Node3D

@onready var ui_label = $CanvasLayer/Label

var is_player_near: bool = false
var is_key_taken: bool = false

func _ready():
	if ui_label:
		ui_label.hide()
	
	if monster_trigger_area:
		monster_trigger_area.hide()
		monster_trigger_area.process_mode = Node.PROCESS_MODE_DISABLED



func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_key_taken:
		is_player_near = true
		if ui_label:
			ui_label.show()


func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_near = false
		if ui_label:
			ui_label.hide()

func _input(event):
	if is_player_near and not is_key_taken and event.is_action_pressed("interact"):
		is_key_taken = true
		if ui_label:
			ui_label.hide()
		
		if key_visual:
			key_visual.hide()
		
		if monster_trigger_area:
			monster_trigger_area.show()
			monster_trigger_area.process_mode = Node.PROCESS_MODE_INHERIT
