extends Area3D


@onready var ui_label = $CanvasLayer/Label
@onready var generator_sound = $GeneratorSound
@onready var door_sound = $DoorSound

var is_player_near: bool = false
var is_activated: bool = false

func _ready():
	ui_label.hide()



func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not is_activated:
		is_player_near = true
		ui_label.show()


func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_player_near = false
		ui_label.hide()

func _input(event):
	if is_player_near and not is_activated and event.is_action_pressed("interact"):
		is_activated = true
		ui_label.hide()
		
		if generator_sound:
			generator_sound.play()
		
		await get_tree().create_timer(5.0).timeout
		
		if door_sound:
			door_sound.play()
		
		var doors = get_tree().get_nodes_in_group("MineDoor")
		for door in doors:
			if door:
				var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(door, "position:z", door.position.z - 3.0, 2.0)
		
		var lights = get_tree().get_nodes_in_group("MineLight")
		for light in lights:
			if light:
				light.show()
