extends CharacterBody2D

# --------------------
# Variables generales
# --------------------
var vida_enemigo: int = 80
var daño_de_ataque: int = 20
var GRAVEDAD = Global.GRAVEDAD
var velocidad: float = 80.0

# Estados del enemigo
enum Estado {
	IDLE,
	PATRULLAR,
	CORRER,
	ATAQUE_MELEE,
	HERIDO,
	MUERTO
}
var estado_actual: Estado = Estado.IDLE

# --------------------
# Nodos y referencias
# --------------------
@onready var collision_shape: CollisionShape2D = $Colision_Entorno
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area_ataque: Area2D = $"Boxes_Daño/Area_Ataque"
# Asumimos que el sprite está en el nodo padre (el mismo que se escalará)
@onready var timer_ataque: Timer = $TimerAtaque
@onready var sprite_2d: Sprite2D = $Animaciones/Sprite2D

# --------------------
# Variables de posicionamiento y rangos
# --------------------
var posicion_inicial: Vector2
var patrol_range: float = 200.0      # Margen de patrulla (a cada lado)
var rango_persecucion: float = 200.0   # Rango para iniciar la persecución
var rango_melee: float = 40.0          # Rango para iniciar el ataque melee

# --------------------
# Variables de estado y control
# --------------------
var ataque_melee: bool = false
var herido: bool = false
var muerto: bool = false

var patrol_timer: float = 0.0
# Control de la dirección: 1 = derecha, -1 = izquierda.
var direccion_num: int = 1

# --------------------
# Funciones principales
# --------------------
func _ready() -> void:
	posicion_inicial = global_position
	randomize()  # Para valores aleatorios en la patrulla

func _physics_process(delta: float) -> void:
	# Si el enemigo está muerto, no hacemos nada.
	if estado_actual == Estado.MUERTO:
		return
	
	# Si está realizando un ataque o se encuentra herido, se omite la lógica de movimiento.
	if ataque_melee or herido or muerto:
		# Forzar que no se mueva horizontalmente durante estas acciones.
		velocity.x = 0
		# Aún se aplicará la gravedad.
		velocity.y += GRAVEDAD * delta
		move_and_slide()
		actualizar_direccion()  # Actualizamos la dirección (mantiene el sprite orientado)
		return
	
	var jugador = obtener_jugador()
	
	if jugador:
		var distancia_al_jugador = position.distance_to(jugador.position)
		# Verificamos que el jugador esté dentro del rango de persecución y no se haya salido de la zona de patrulla.
		var jugador_offset = jugador.position.x - posicion_inicial.x
		if distancia_al_jugador <= rango_persecucion and abs(jugador_offset) <= patrol_range:
			# Si está dentro del rango de ataque y el Timer está listo, ataca.
			if distancia_al_jugador <= rango_melee and timer_ataque.is_stopped():
				mover_hacia(jugador.position)
				cambiar_estado(Estado.ATAQUE_MELEE)
				timer_ataque.start()
			else:
				mover_hacia(jugador.position)
				cambiar_estado(Estado.CORRER)
		else:
			# Si el jugador se aleja demasiado, vuelve a patrullar.
			_patrol(delta)
	else:
		# Sin jugador, se patrulla.
		_patrol(delta)
	
	# Aplicar gravedad y mover.
	velocity.y += GRAVEDAD * delta
	move_and_slide()
	# Actualizar la orientación del sprite basándose en la velocidad horizontal.
	actualizar_direccion()

# --------------------
# Función de patrulla aleatoria
# --------------------
func _patrol(delta: float) -> void:
	patrol_timer -= delta
	if patrol_timer <= 0:
		# Escoge aleatoriamente una dirección.
		direccion_num = 1 if (randi() % 2 == 0) else -1
		patrol_timer = randf_range(1.0, 3.0)
	
	# Si se sale del rango permitido, forzamos que se vuelva a la zona.
	if position.x > posicion_inicial.x + patrol_range:
		direccion_num = -1
		patrol_timer = randf_range(1.0, 3.0)
	elif position.x < posicion_inicial.x - patrol_range:
		direccion_num = 1
		patrol_timer = randf_range(1.0, 3.0)
	
	velocity.x = direccion_num * velocidad
	cambiar_estado(Estado.PATRULLAR)

# --------------------
# Funciones auxiliares
# --------------------
func actualizar_direccion() -> void:
	# Basamos la dirección en la velocidad horizontal.
	if velocity.x > 0:
		direccion_num = 1
	elif velocity.x < 0:
		direccion_num = -1
	# Actualizamos la escala del nodo para invertir el sprite.
	sprite_2d.flip_h = (direccion_num == -1)
	area_ataque.scale.x = 1 if direccion_num == 1 else -1

func mover_hacia(destino: Vector2) -> void:
	var diff = destino.x - position.x
	if diff == 0:
		velocity.x = 0
		return
	var dir = Vector2(diff, 0).normalized()
	velocity.x = dir.x * velocidad

func cambiar_estado(nuevo_estado: Estado) -> void:
	# Si se quiere cambiar a MUERTO, dar prioridad.
	if nuevo_estado == Estado.MUERTO:
		muerto = true
		ataque_melee = false
		herido = false
		estado_actual = nuevo_estado
		animation_player.play("Muerte")
		return
		
	if nuevo_estado == Estado.HERIDO:
		muerto = false
		ataque_melee = false
		herido = true
		estado_actual = nuevo_estado
		animation_player.play("Herido")
		return
	# Si ya se encuentra en una acción ininterrumpible, no se cambia de estado.
	if ataque_melee or herido or muerto:
		return
	
	estado_actual = nuevo_estado
	match nuevo_estado:
		Estado.IDLE:
			animation_player.play("Idle")
		Estado.PATRULLAR:
			animation_player.play("Andar")
		Estado.CORRER:
			animation_player.play("Andar")
		Estado.ATAQUE_MELEE:
			ataque_melee = true
			# Para que el enemigo se quede quieto durante el ataque, forzamos velocidad.x a 0.
			velocity.x = 0
			animation_player.play("Ataque")
		Estado.HERIDO:
			herido = true
			animation_player.play("Herido")

func obtener_jugador() -> Node2D:
	var jugadores = get_tree().get_nodes_in_group("player")
	if jugadores.size() > 0:
		return jugadores[0] as Node2D
	return null

# Se llama al finalizar una animación importante para restablecer los flags.
func _on_animation_finished(anim_name: String) -> void:
	ataque_melee = false
	herido = false

# Lógica de eliminación y dropeo de ítems
func _on_eliminar_enemigo() -> void:
	var dropped_item = Global.Dropear_Items_Normales()
	dropped_item.global_position = global_position
	get_tree().current_scene.add_child(dropped_item)
	queue_free()

func hacer_daño() -> int:
	return daño_de_ataque

func recibir_daño(daño: int) -> void:
	if estado_actual == Estado.MUERTO:
		return
	vida_enemigo = max(vida_enemigo - daño, 0)
	print("Enemigo recibió daño:", daño, "Vida actual:", vida_enemigo)
	if vida_enemigo == 0:
		cambiar_estado(Estado.MUERTO)
	else:
		cambiar_estado(Estado.HERIDO)
