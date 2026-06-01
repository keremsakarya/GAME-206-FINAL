extends Area3D

# Kameranın bakacağı hedefi Inspector'dan seçeceğiz
@export var look_target: Node3D 

@onready var ui_label = $CanvasLayer/Label

var has_triggered = false # Sinematik sadece 1 kere çalışsın diye şalter koyuyoruz
var player_node: Node3D = null
var camera_node: Camera3D = null
var original_camera_transform: Transform3D

func _ready():
	ui_label.hide()

func start_cinematic():
	# 1. Oyuncuyu Kilitle
	if "can_move" in player_node:
		player_node.can_move = false
		
	ui_label.show()
	
	# 2. SİHİRLİ SATIR: Kameranın bozulmadan önceki o "kusursuz" ilk halini hafızaya al
	original_camera_transform = camera_node.global_transform
	
	# 3. Kamerayı hedefe çevir (1.5 saniye)
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var target_transform = camera_node.global_transform.looking_at(look_target.global_position, Vector3.UP)
	tween.tween_property(camera_node, "global_transform", target_transform, 1.5)
	
	# 4. Toplam 5 Saniye Bekle (Dönüşe de 1 sn ayıracağımız için 5 yaptık)
	await get_tree().create_timer(5.0).timeout
	
	# 5. Kamerayı pürüzsüzce hafızaya aldığımız o "ilk haline" geri döndür! (1 saniye)
	var tween_back = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_back.tween_property(camera_node, "global_transform", original_camera_transform, 1.0)
	
	# Geri dönüş animasyonunun bitmesini bekle
	await tween_back.finished
	
	# 6. Her şeyi temizle ve kontrolleri geri ver
	ui_label.hide()
	
	if "can_move" in player_node:
		player_node.can_move = true
		
	queue_free()

# --- SİNYALLER ---
func _on_body_entered(body: Node3D) -> void:
	# Oyuncu alana girdiyse ve olay henüz tetiklenmediyse
	if body.name == "Player" and not has_triggered:
		has_triggered = true
		player_node = body
		
		# Oyuncunun kamerasını buluyoruz (DİKKAT: Oyuncu içindeki kameranın adı Camera3D değilse burayı değiştir)
		camera_node = player_node.get_node_or_null("Camera3D")
		
		# Kamera ve hedef varsa motoru çalıştır!
		if camera_node and look_target:
			start_cinematic()
