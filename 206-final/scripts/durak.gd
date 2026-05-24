extends Node3D

@onready var bus_model = $Path3D/PathFollow3D/Bus2
@onready var anim_player = $Path3D/AnimationPlayer
@onready var bus_audio = $Path3D/PathFollow3D/Bus2/BusAudio

@onready var bus_interact: Area3D = $ATMInteract

func _ready() -> void:
	bus_model.hide()
	anim_player.stop()
	
	bus_interact.monitoring = false
	bus_interact.hide()
	
	await get_tree().create_timer(20.0).timeout
	
	bus_audio.play()
	
	await get_tree().create_timer(13.0).timeout
	
	bus_model.show()
	anim_player.play("otobüshareket")
	
	await get_tree().create_timer(10.0).timeout
	
	bus_interact.show()
	bus_interact.monitoring = true
