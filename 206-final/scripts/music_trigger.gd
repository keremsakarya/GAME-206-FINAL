extends Area3D

@onready var music_player = $AmbientPlayer
var fade_tween: Tween

# We will create a blank space to remember your custom volume
var target_volume: float 

func _ready() -> void:
	# 1. The moment the game starts, memorize whatever volume you typed in the Inspector!
	target_volume = music_player.volume_db
	
	# 2. Connect the wires
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		
		if fade_tween and fade_tween.is_valid():
			fade_tween.kill()
			
		music_player.volume_db = -40.0 
		music_player.play()
		
		# 3. Fade the music up to your memorized volume!
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", target_volume, 2.5).set_trans(Tween.TRANS_SINE)

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		
		if fade_tween and fade_tween.is_valid():
			fade_tween.kill()
			
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", -40.0, 2.0).set_trans(Tween.TRANS_SINE)
		fade_tween.tween_callback(music_player.stop)
