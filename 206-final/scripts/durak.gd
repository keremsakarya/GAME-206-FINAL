extends Node3D

@onready var bus_model = $Path3D/PathFollow3D/Bus2
@onready var anim_player = $Path3D/AnimationPlayer


func _ready() -> void:
	bus_model.hide()
	anim_player.stop()
	await get_tree().create_timer(30.0).timeout
	
	bus_model.show()
	anim_player.play("otobüshareket")
