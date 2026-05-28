extends Area3D

@onready var music_player = $HouseMusic
var fade_tween: Tween

func _ready() -> void:
	# Wires are hard-coded!
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	# BYPASSING GROUPS ENTIRELY: Just check the physical name!
	if body.name == "Player":
		
		if fade_tween and fade_tween.is_valid():
			fade_tween.kill()
			
		music_player.volume_db = -40.0 
		music_player.play()
		
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", 0.0, 2.5).set_trans(Tween.TRANS_SINE)

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		
		if fade_tween and fade_tween.is_valid():
			fade_tween.kill()
			
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", -40.0, 2.0).set_trans(Tween.TRANS_SINE)
		fade_tween.tween_callback(music_player.stop)
