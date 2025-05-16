extends StaticBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D2
@onready var label: Label = $Label2
@onready var flecha_camino: Sprite2D = $Flecha_Camino

var jugador_en_area: bool = false

func _ready() -> void:
	label.visible = false
	animated_sprite_2d.play("Giro")
	

func _process(delta: float) -> void:
	if jugador_en_area and Input.is_action_just_pressed("F_Interactuar"):
		var mapa_nuevo = Global.cargar_siguiente_mapa("ZONA_SEGURA")
		get_tree().change_scene_to_file(mapa_nuevo.resource_path)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_en_area = true
		label.visible = true
		flecha_camino.visible = false


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jugador_en_area = false
		label.visible = false
		flecha_camino.visible = true
