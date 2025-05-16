extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cofre_area: Area2D = $Area2D
@onready var sonido_cofre: AudioStreamPlayer2D = $Abrir_Cofre

var picked_up: bool = false
var GRAVEDAD = Global.GRAVEDAD  # Traemos la gravedad desde el global

var item_normal_scenes = Global.ITEMS_DROPEABLES_NORMALES
var item_especial_scenes = Global.ITEMS_DROPEABLES_ESPECIALES
var probabilidad_especial = 0.05  # Probabilidad de cofre especial 

func _ready() -> void:
	cofre_area.body_entered.connect(_on_cofre_area_body_entered)
	sprite.play("Sin_Abrir")

func _process(delta: float) -> void:
	if !picked_up:
		apply_central_force(Vector2(0, GRAVEDAD))  # Aplicamos la fuerza de la gravedad

func _on_cofre_area_body_entered(body: Node) -> void:
	# Si ya fue recogido, no hacemos nada.
	if picked_up:
		return

	if body.is_in_group("player") and EstadisticasPlayer.llaves >= 1:
		EstadisticasPlayer.llaves -= 1
		picked_up = true  # Marcamos como recogido.
		sonido_cofre.play()

		# Determinar si es un cofre especial o normal
		var es_especial = randf() < probabilidad_especial
		if es_especial:
			sprite.play("Abierto_Especial")
			spawn_items(es_especial, 4, 5)
		else:
			sprite.play("Abierto_Normal")
			spawn_items(es_especial, 1, 3)

		# Deshabilita su colisión
		cofre_area.monitoring = false

		# Conecta la señal para detectar el final de la animación de apertura
		sprite.animation_finished.connect(_on_animation_finished)

func spawn_items(es_especial: bool, min_items: int, max_items: int) -> void:
	var num_items = randi_range(min_items, max_items)
	# Selecciona la lista de items adecuada
	var item_scenes = []
	if es_especial:
		# Cofre especial: combina items normales y especiales
		item_scenes = item_normal_scenes + item_especial_scenes
	else:
		# Cofre normal: sólo items normales
		item_scenes = item_normal_scenes

	for i in range(num_items):
		var item_scene = item_scenes[randi() % item_scenes.size()]
		var item_instance = item_scene.instantiate()
		# Ajustar la posición del ítem para que aparezca más alto que el cofre
		item_instance.position = global_position + Vector2(randf_range(-20, 20), randf_range(-80, -40))
		get_parent().add_child(item_instance)

func _on_animation_finished():
	sonido_cofre.stop()
	sprite.play("Cofre_Ya_Abierto")
