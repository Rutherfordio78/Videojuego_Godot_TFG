extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_comprar: Area2D = $Area2D
@onready var sonidos: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var menu_tienda = $Pop_Up_Tienda


func _ready() -> void:
	sprite.play("default")
	menu_tienda.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("player entro en la tienda")
	if body.is_in_group("player"):
		menu_tienda.visible = true



func _on_area_2d_body_exited(body: Node2D) -> void:
	print("player salio de la tienda")
	if body.is_in_group("player"):
		menu_tienda.visible = false
