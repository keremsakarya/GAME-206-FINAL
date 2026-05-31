extends Node3D

@onready var tripwire = $Area3D

func _ready() -> void:
	# Wire up the physical tripwire
	tripwire.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Make sure it's actually the player crossing the line, not a random physics object
	if body.name == "Player":
		
		# Instantly delete the stalker forever!
		queue_free()
