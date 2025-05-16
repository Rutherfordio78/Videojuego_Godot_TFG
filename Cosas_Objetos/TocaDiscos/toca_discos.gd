extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_TocaDiscos: Area2D = $Area2D

@onready var menu_TocaDiscos = $Pop_Up_TocaDiscos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	menu_TocaDiscos.visible = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("player entro en el TocaDiscos")
	if body.is_in_group("player"):
		menu_TocaDiscos.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	print("player salio de el TocaDiscos")
	if body.is_in_group("player"):
		menu_TocaDiscos.visible = false
