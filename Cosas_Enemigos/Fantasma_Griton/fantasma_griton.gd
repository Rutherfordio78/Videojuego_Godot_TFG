extends CharacterBody2D

# Variables de propiedades del murciélago
var vida_enemigo: int = 25
var daño_de_ataque: int = 10
var GRAVEDAD = Global.GRAVEDAD
var velocidad: float = 80.0

# Distancias para detectar al player y para ataque
var distancia_despertar: float = 300.0
var rango_perseguir: float = 300.0
var rango_ataque: float = 50.0
var radio_movimiento: float = 200.0

# Estados del murciélago
enum Estado {
	IDLE_VOLAR,
	PERSEGUIR,
	ATAQUE,
	HERIDO,
	MUERTO
}
var estado_actual: Estado = Estado.IDLE_VOLAR

# Nodos referenciados
@onready var colision_entorno: CollisionShape2D = $Colision_Entorno
@onready var sprite_2d: Sprite2D = $Animaciones/Sprite2D
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer
@onready var area_ataque: Area2D = $"Boxes_Daño/Area_Ataque"
@onready var colision_ataque: CollisionShape2D = $"Boxes_Daño/Area_Ataque/Colision_Ataque"
@onready var area_herido: Area2D = $"Boxes_Daño/Area_Herido"
@onready var colision_herido: CollisionShape2D = $"Boxes_Daño/Area_Herido/Colision_Herido"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer


# Variables para movimiento aleatorio en estado IDLE_VOLAR
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	randomize() # Para movimientos aleatorios
	animation_player.play("Idle")

func _physics_process(delta: float) -> void:
	
	if estado_actual == Estado.HERIDO:
		return
	
	match estado_actual:
		Estado.IDLE_VOLAR:
			process_idle_volar(delta)
		Estado.PERSEGUIR:
			process_perseguir(delta)
		Estado.ATAQUE:
			process_ataque(delta)
		Estado.HERIDO:
			process_herido(delta)
		Estado.MUERTO:
			process_muerto(delta)

# Estado IDLE_VOLAR: movimiento aleatorio y detección para iniciar persecución
func process_idle_volar(delta: float) -> void:
	if target_position == Vector2.ZERO or global_position.distance_to(target_position) < 10:
		assign_random_target()
	var direction = global_position.direction_to(target_position)
	velocity = direction * velocidad
	move_and_slide()
	sprite_2d.flip_h = velocity.x > 0

	# Si el jugador se encuentra en rango de persecución, pasamos a PERSEGUIR
	var player_pos = get_player_position()
	if global_position.distance_to(player_pos) < rango_perseguir:
		estado_actual = Estado.PERSEGUIR

# Estado PERSEGUIR: el murciélago se dirige hacia el jugador
func process_perseguir(delta: float) -> void:
	animation_player.play("Correr")
	var player_pos = get_player_position()
	var direction = global_position.direction_to(player_pos)
	velocity = direction * velocidad
	move_and_slide()
	sprite_2d.flip_h = velocity.x > 0
	
	var dist_to_player = global_position.distance_to(player_pos)
	# Si el jugador está lo suficientemente cerca y el cooldown permite atacar, cambiamos a ATAQUE
	if dist_to_player < rango_ataque and timer.is_stopped():
		estado_actual = Estado.ATAQUE
		# Seleccionamos animación de ataque según la posición relativa
		animation_player.play("Ataque")
		timer.start()
	# Si el jugador se aleja, volvemos a IDLE_VOLAR
	elif dist_to_player > rango_perseguir:
		estado_actual = Estado.IDLE_VOLAR
		animation_player.play("Idle")

# Estado ATAQUE: el murciélago ataca al jugador
func process_ataque(delta: float) -> void:
	var player_pos = get_player_position()
	var direction = global_position.direction_to(player_pos)
	velocity = direction * (velocidad * 1.5)
	# No actualizamos flip_h aquí, ya que la animación de ataque ya define la orientación.
	move_and_slide()

	# Si el jugador se aleja del rango de ataque, volvemos a PERSEGUIR
	if global_position.distance_to(player_pos) > rango_ataque * 1.5:
		estado_actual = Estado.PERSEGUIR
		animation_player.play("Correr")

# Estado HERIDO: se muestra efecto herido y se retorna a vuelo inactivo
func process_herido(delta: float) -> void:
	estado_actual = Estado.IDLE_VOLAR
	animation_player.play("Idle")

# Estado MUERTO: reproducir animación de muerte y desactivar colisiones (si se requiere)
func process_muerto(delta: float) -> void:
	animation_player.play("Muerte")
	# Opcional: desactivar colisiones

func eliminar_enemigo():
	var dropped_item = Global.Dropear_Items_Normales()
	dropped_item.global_position = global_position
	get_tree().current_scene.add_child(dropped_item)
	
	queue_free()

# Asigna un nuevo objetivo aleatorio para el movimiento
func assign_random_target() -> void:
	var random_offset = Vector2(
		randf_range(-radio_movimiento, radio_movimiento),
		randf_range(-radio_movimiento, radio_movimiento)
	)
	target_position = global_position + random_offset

# Obtiene la posición del jugador (se asume que está en el grupo "player")
func get_player_position() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0].global_position - Vector2(10, 10)
	return global_position

func hacer_daño() -> int:
	return daño_de_ataque

# Función para recibir daño
func recibir_daño(daño_recibido: int) -> void:
	if estado_actual == Estado.MUERTO:
		return
	vida_enemigo = max(vida_enemigo - daño_recibido, 0)
	print("Fantasma Griton recibió daño: ", daño_recibido, " | Vida actual:", vida_enemigo)
	
	if vida_enemigo <= 0:
		estado_actual = Estado.MUERTO
		animation_player.play("Muerte")
	else:
		estado_actual = Estado.HERIDO
		animation_player.play("Herido")


# Callback de fin de animación para gestionar transiciones
func _on_animation_finished(anim_name: String) -> void:
	# Si finaliza una animación de ataque, se revisa la distancia para decidir si se sigue atacando o se pasa a perseguir
	if estado_actual == Estado.ATAQUE:
		estado_actual = Estado.IDLE_VOLAR
		animation_player.play("Idle")
	# Si termina la animación de herido, se vuelve al vuelo inactivo
	elif estado_actual == Estado.HERIDO:
		estado_actual = Estado.IDLE_VOLAR
		animation_player.play("Idle")
