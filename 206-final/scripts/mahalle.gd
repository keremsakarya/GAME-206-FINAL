extends Node3D

@onready var player = $Player


func _ready() -> void:
	if player:
		player.can_move = false
	
	await get_tree().create_timer(12.0).timeout
	
	if player:
		player.can_move = true
