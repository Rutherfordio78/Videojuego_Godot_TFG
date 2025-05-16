extends CharacterBody2D

# --------------------
# Variables generales
# --------------------
var vida_enemigo: int = 100
var daño_de_ataque: int = 10
var GRAVEDAD = Global.GRAVEDAD
var velocidad: float = 200.0

# Estados del enemigo
enum Estado {
	IDLE,
	CORRER,
	ATAQUE_MELEE,
	ATAQUE_HECHIZO,
	HERIDO,
	MUERTO
}
var estado_actual: Estado = Estado.IDLE

# Variable para controlar si el enemigo debe regresar a su posición inicial
var is_returning: bool = false

# --------------------
# Nodos y referencias
# --------------------
@onready var boxes_dano = $"Boxes_Daño"
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# --------------------
# Variables de posicionamiento y rangos
# --------------------
var posicion_inicial: Vector2

# Rangos ajustables (valores de ejemplo, modifícalos según tu necesidad)
var rango_hechizo: float = 400.0      # Rango para lanzar el hechizo (ataque a distancia)
var rango_persecucion: float = 180.0   # Rango desde el cual inicia la persecución
var rango_melee: float = 60.0         # Rango en el que se activa el ataque melee
var max_distancia: float = 400.0       # Distancia máxima que el enemigo se aleja de su posición inicial

# --------------------
# Variables para cooldown de ataques
# --------------------
var tiempo_espera_hechizo: float = 2.0
var timer_espera_hechizo: float = 0.0

var tiempo_espera_melee: float = 1.0
var timer_espera_melee: float = 0.0

# --------------------
# Variable para control de dirección (1: derecha, -1: izquierda)
# --------------------
var direccion_num: int = 1

# --------------------
# Variables de estado
# --------------------
var ataque_melee = false
var ataque_hechizo = false
var herido = false
var muerto = false
var idle = false
var correr = false

# --------------------
# Métodos de inicialización
# --------------------
func _ready() -> void:
	# Guardamos la posición inicial para regresar cuando sea necesario
	posicion_inicial = position
	# Conectar señales de daño
	boxes_dano.connect("Algo_Golpeado", Callable(self, "_on_Algo_Golpeado"))
	boxes_dano.connect("Golpe_Recibido", Callable(self, "_on_Golpe_Recibido"))

# --------------------
# Bucle principal de física
# --------------------
func _physics_process(delta: float) -> void:
	
	# Si se está en medio de una acción importante, no se procesa el movimiento.
	if ataque_melee or ataque_hechizo or herido or muerto:
		return
	
	if estado_actual == Estado.MUERTO:
		return
		
	var jugador = obtener_jugador()
	if not jugador:
		return

	var distancia_al_jugador = position.distance_to(jugador.position)
	var distancia_al_inicio = position.distance_to(posicion_inicial)
	
	if timer_espera_hechizo > 0:
		timer_espera_hechizo -= delta
	if timer_espera_melee > 0:
		timer_espera_melee -= delta

	# Lógica usando la bandera is_returning:
	if is_returning:
		# Mientras se esté regresando, ignoramos al jugador y forzamos el retorno
		actualizar_direccion(posicion_inicial)
		if distancia_al_inicio > 10:
			mover_hacia(posicion_inicial)
			cambiar_estado(Estado.CORRER)
		else:
			velocity.x = 0  # Forzamos la posición para eliminar oscilaciones.
			cambiar_estado(Estado.IDLE)
			is_returning = false  # Una vez llegado, se desactiva el retorno.
	else:
		# Si no se está regresando, se verifica si se excede la distancia permitida.
		if distancia_al_inicio >= max_distancia:
			is_returning = true
			actualizar_direccion(posicion_inicial)
			mover_hacia(posicion_inicial)
			cambiar_estado(Estado.CORRER)
		else:
			# Lógica de persecución y ataque
			if distancia_al_jugador <= rango_melee and timer_espera_melee <= 0:
				actualizar_direccion(jugador.position)
				mover_hacia(jugador.position)
				cambiar_estado(Estado.ATAQUE_MELEE)
				timer_espera_melee = tiempo_espera_melee

			elif distancia_al_jugador <= rango_persecucion:
				actualizar_direccion(jugador.position)
				mover_hacia(jugador.position)
				cambiar_estado(Estado.CORRER)
			
			elif distancia_al_jugador <= rango_hechizo and timer_espera_hechizo <= 0:
				actualizar_direccion(jugador.position)
				cambiar_estado(Estado.ATAQUE_HECHIZO)
				timer_espera_hechizo = tiempo_espera_hechizo
			
			else:
				# Si el jugador se aleja, el enemigo regresa a su posición inicial.
				actualizar_direccion(posicion_inicial)
				if distancia_al_inicio > 10:
					mover_hacia(posicion_inicial)
					cambiar_estado(Estado.CORRER)
				else:
					velocity.x = 0
					cambiar_estado(Estado.IDLE)
	
	# Aplicar gravedad:
	velocity.y += GRAVEDAD * delta
	# En Godot 4, move_and_slide() se llama sin argumentos.
	move_and_slide()

# --------------------
# Funciones de utilidades
# --------------------
func _on_animation_finished(anim_name: String) -> void:
	ataque_melee = false
	ataque_hechizo = false
	herido = false

# Obtener el jugador mediante el grupo "jugador"
func obtener_jugador() -> Node2D:
	var jugadores = get_tree().get_nodes_in_group("player")
	if jugadores.size() > 0:
		return jugadores[0] as Node2D
	return null

# Actualiza la variable de dirección según la posición del target
func actualizar_direccion(target_pos: Vector2) -> void:
	if target_pos.x < position.x:
		direccion_num = -1
	else:
		direccion_num = 1

# Mueve al enemigo hacia un destino dado
func mover_hacia(destino: Vector2) -> void:
	var diferencia_x = destino.x - position.x
	# Evitamos división por cero si no hay diferencia
	if diferencia_x == 0:
		velocity.x = 0
		return
	var dir = Vector2(diferencia_x, 0).normalized()
	velocity.x = dir.x * velocidad

# Lanza el hechizo (instancia la escena y la posiciona ligeramente sobre el jugador)
func lanzar_hechizo():
	var jugador = obtener_jugador()
	if not jugador:
		return
	
	var posicion_jugador = jugador.position
	
	var hechizo_scene = preload("res://Cosas_Enemigos/Caos_Maker/rayo_sombrio.tscn")
	var hechizo_instance = hechizo_scene.instantiate()
	hechizo_instance.position = posicion_jugador + Vector2(0, -29)
	get_parent().add_child(hechizo_instance)

func cambiar_estado(nuevo_estado: Estado) -> void:
	# Si se quiere pasar al estado MUERTO, dar prioridad y anular otras acciones.
	if nuevo_estado == Estado.MUERTO:
		muerto = true
		ataque_melee = false
		ataque_hechizo = false
		herido = false
		idle = false
		correr = false
	# Si se quiere pasar al estado HERIDO, se interrumpen los ataques activos.
	elif nuevo_estado == Estado.HERIDO:
		ataque_melee = false
		ataque_hechizo = false
	# Para otros estados, se evita cambiar si ya se está en medio de una acción que debe completarse.
	elif ataque_melee or ataque_hechizo or herido or muerto:
		return

	estado_actual = nuevo_estado

	match nuevo_estado:
		Estado.IDLE:
			idle = true
			animation_player.play("Idle_Derecha" if direccion_num == 1 else "Idle_Izquierda")
		Estado.CORRER:
			correr = true
			animation_player.play("Correr_Derecha" if direccion_num == 1 else "Correr_Izquierda")
		Estado.ATAQUE_MELEE:
			ataque_melee = true
			animation_player.play("Ataque_Mele_Derecha" if direccion_num == 1 else "Ataque_Mele_Izquierda")
		Estado.ATAQUE_HECHIZO:
			ataque_hechizo = true
			animation_player.play("Hechizo_Derecha" if direccion_num == 1 else "Hechizo_Izquierda")
		Estado.HERIDO:
			herido = true
			animation_player.play("Herido_Derecha" if direccion_num == 1 else "Herido_Izquierda")
		Estado.MUERTO:
			animation_player.play("Muerte_Derecha" if direccion_num == 1 else "Muerte_Izquierda")


# --------------------
# Lógica de daño (ya existente)
# --------------------
func _on_eliminar_enemigo() -> void:
	# Instancia el ítem dropeado usando la función global
	var dropped_item = Global.Dropear_Items_Normales()
	# Posiciona el ítem en la ubicación del enemigo
	dropped_item.global_position = global_position
	# Agrega el ítem a la escena actual
	get_tree().current_scene.add_child(dropped_item)
	# Elimina el enemigo
	queue_free()


func hacer_daño() -> int:
	return daño_de_ataque

func recibir_daño(daño_Recibido: int) -> void:
	if estado_actual == Estado.MUERTO:
		return
	vida_enemigo = max(vida_enemigo - daño_Recibido, 0)
	print("Enemigo recibió daño: ", daño_Recibido, "Vida actual:", vida_enemigo)
	
	if vida_enemigo == 0:
		cambiar_estado(Estado.MUERTO)
	else:
		cambiar_estado(Estado.HERIDO)
