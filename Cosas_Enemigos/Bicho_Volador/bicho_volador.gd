extends CharacterBody2D

# Constantes de velocidad y fade al morir
const SPEED = 300.0
const FADE_SPEED = 2.0
const CHASE_DISTANCE = 300.0  # Distancia a la que el enemigo empieza a perseguir al player
const RANDOM_MOVE_RADIUS = 200.0  # Radio para seleccionar una posición aleatoria

# Nodos referenciados
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

# Propiedades del enemigo
var vida_Enemigo = 30
var daño_de_ataque = 10

# Variables para efecto flash cuando recibe daño
var flash_duration: float = 0.3
var flash_timer: float = 0.0
var tiempo_espera: float = 0.5
var timer_espera: float = 0.0

# Estados del enemigo
enum State {
	VOLAR,
	HURT,
	DEAD
}
var estado_actual: State = State.VOLAR

func _ready() -> void:
	animated_sprite_2d.play("Volar")
	audio_stream_player_2d.play()

func _physics_process(delta: float) -> void:
	match estado_actual:
		State.VOLAR:
			var player_pos = get_player_position()
			if global_position.distance_to(player_pos) < CHASE_DISTANCE:
				# Si el jugador está cerca, perseguirlo
				process_movement(delta)
			else:
				# Si no, moverse aleatoriamente
				movimiento_aleatorio(delta)
		State.HURT:
			process_hurt(delta)
		State.DEAD:
			process_death(delta)

# Función para obtener la posición del player
func get_player_position() -> Vector2:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0].global_position
	# Si no hay player en la escena, se queda en la posición actual
	return global_position

# Procesa el movimiento del enemigo cuando está en estado VOLAR
func process_movement(delta: float) -> void:
	# Ahora se obtiene la posición del player en vez del ratón
	var target_position = get_player_position()
	navigation_agent_2d.target_position = target_position
	
	var current_agent_position = global_position
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * SPEED
	
	# Ajustamos el flip del sprite: si se mueve a la derecha, se invierte horizontalmente
	if new_velocity.x > 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		if navigation_agent_2d.avoidance_enabled:
			navigation_agent_2d.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()

# Función para el movimiento aleatorio en la NavigationRegion
func movimiento_aleatorio(delta: float) -> void:
	# Si hemos alcanzado el objetivo aleatorio o no hay ruta válida, asignamos uno nuevo
	if navigation_agent_2d.is_navigation_finished():
		asignar_objetivo_aleatorio()
	
	# Obtener la siguiente posición en la ruta
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position) * SPEED
	
	# Ajustamos el flip del sprite
	animated_sprite_2d.flip_h = new_velocity.x > 0
	
	# Si hay obstáculos o se necesita evitar, se deja que el NavigationAgent2D procese la velocidad
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	move_and_slide()

# Asigna un nuevo objetivo aleatorio dentro de un radio alrededor de la posición actual
func asignar_objetivo_aleatorio() -> void:
	var random_offset = Vector2(
		randf_range(-RANDOM_MOVE_RADIUS, RANDOM_MOVE_RADIUS),
		randf_range(-RANDOM_MOVE_RADIUS, RANDOM_MOVE_RADIUS)
	)
	# Aquí se asume que la posición aleatoria es válida dentro de la región de navegación.
	# Si es necesario, se puede validar con NavigationServer2D.
	navigation_agent_2d.target_position = global_position + random_offset


# Procesa el estado HURT, mostrando el flash rojo y luego regresando al estado VOLAR
func process_hurt(delta: float) -> void:
	flash_timer -= delta
	if flash_timer <= 0:
		# Restaura el color normal
		animated_sprite_2d.modulate = Color(1, 1, 1, 1)
		timer_espera -= delta
		if timer_espera <= 0:
			estado_actual = State.VOLAR

# Procesa la muerte: se desvanece el sprite y luego se elimina el nodo
func process_death(delta: float) -> void:
	$Area_Ataque/CollisionShape2D.disabled = true
	var current_color = animated_sprite_2d.modulate
	current_color.a = max(current_color.a - FADE_SPEED * delta, 0)
	animated_sprite_2d.modulate = current_color
	if current_color.a <= 0:
		# Si tienes una función global para dropear ítems, se invoca aquí (asegúrate de que Global tenga el método)
		if Global.has_method("Dropear_Items_Normales"):
			var dropped_item = Global.Dropear_Items_Normales()
			dropped_item.global_position = global_position
			get_tree().current_scene.add_child(dropped_item)
		queue_free()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

# Retorna el daño que hace este enemigo
func hacer_daño() -> int:
	return daño_de_ataque

# Recibe daño y actualiza el estado del enemigo
func recibir_daño(daño_Recibido: int) -> void:
	if estado_actual == State.DEAD:
		return
	vida_Enemigo = max(vida_Enemigo - daño_Recibido, 0)
	print("Enemigo recibió daño: ", daño_Recibido, " | Vida actual:", vida_Enemigo)
	if vida_Enemigo <= 0:
		estado_actual = State.DEAD
		# Opcional: reproducir sonido de muerte, cambiar animación, etc.
	else:
		estado_actual = State.HURT
		_flash_red()

# Activa el efecto flash rojo
func _flash_red() -> void:
	animated_sprite_2d.modulate = Color(1, 0, 0, 1)
	flash_timer = flash_duration
	timer_espera = tiempo_espera
