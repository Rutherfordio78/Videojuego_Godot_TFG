extends CharacterBody2D

# Variables Globales
var GRAVEDAD = Global.GRAVEDAD

# Variable Caerse del mapa
var ultimo_suelo 

var ultimo_ataque: String

# Dirección del personaje (puedes usar esto para hacer flip en el Sprite).
var direccion_num: int

# Referencias a nodos
@onready var colision_entorno: CollisionShape2D = $Colision_Entorno
@onready var sprite_2d: Sprite2D = $Animaciones/Sprite2D													
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer

@onready var area_ataque: Area2D = $"Boxes_Daño/Area_Ataque"
@onready var colision_ataque_dash: CollisionShape2D = $"Boxes_Daño/Area_Ataque/Colision_Ataque_Dash"
@onready var colision_ataque_ligero_1: CollisionShape2D = $"Boxes_Daño/Area_Ataque/Colision_Ataque_Ligero_1"
@onready var colision_ataque_ligero_2: CollisionShape2D = $"Boxes_Daño/Area_Ataque/Colision_Ataque_Ligero_2"


@onready var area_herido: Area2D = $"Boxes_Daño/Area_Herido"
@onready var colision_herido: CollisionShape2D = $"Boxes_Daño/Area_Herido/Colision_Herido"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var cooldown_timer_ataque_ligero: Timer = $Timers/Cooldown_Timer_Ataque_Ligero
@onready var combo_timer_ataque_ligero: Timer = $Timers/Combo_Timer_Ataque_Ligero
@onready var cooldown_dash: Timer = $Timers/Cooldown_Dash
@onready var cooldown_dash_ataque: Timer = $Timers/Cooldown_Dash_Ataque
@onready var menu_pausar_juego: Control = $Menu_Pausar_Juego

# --------------------
# Variables para Knockback
# --------------------
var knockback: Vector2 = Vector2.ZERO
var knockback_strength: float = 200.0  # Ajusta según la fuerza deseada
var knockback_friction: float = 300.0  # Velocidad a la que se reduce el knockback

var deslizarse: Vector2 = Vector2.ZERO
var deslizarse_strength: float = 400.0  # Ajusta según la fuerza deseada
var deslizarse_friction: float = 300.0  # Velocidad a la que se reduce el knockback

# Definimos los estados posibles para el jugador.
enum Estado {
	IDLE,
	CORRER,
	SALTAR,
	ATAQUE_LIGERO,
	ATAQUE_FUERTE_DASH,
	DASH,
	DESLIZARSE,
	HERIDO,
	MUERTO
}

var estado_actual: Estado = Estado.IDLE


func _ready() -> void:
	ultimo_suelo = global_position
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		menu_pausar_juego.visible = get_tree().paused

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	
	EstadisticasPlayer.posicion_Player = global_position
	
	if EstadisticasPlayer.vida_actual_Player == 0:
		estado_actual = Estado.MUERTO
	
	if estado_actual == Estado.MUERTO:
		_update_animation()
		return
		
	var input_vector = Vector2.ZERO
	
	# --- LECTURA DE ENTRADAS ---
	# Movimiento horizontal.
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("Moverse_Derecha_Mando"):
		input_vector.x += 1
		direccion_num = 1
		
		colision_ataque_dash.position = Vector2(19, 0)
		colision_ataque_dash.rotation = -49.1
		
		colision_ataque_ligero_1.position = Vector2(14, -5)
		colision_ataque_ligero_1.rotation = -65.5
		
		colision_ataque_ligero_2.position = Vector2(-2, -7)
		colision_ataque_ligero_2.rotation = -73.6
		
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("Moverse_Izquierda_Mando"):
		input_vector.x -= 1
		direccion_num = -1
		colision_ataque_dash.position = Vector2(-19, 0)
		colision_ataque_dash.rotation = 49.1
		
		colision_ataque_ligero_1.position = Vector2(-14, -5)
		colision_ataque_ligero_1.rotation = 65.5
		
		colision_ataque_ligero_2.position = Vector2(2, -7)
		colision_ataque_ligero_2.rotation = 73.6
		

	# --- Ataque Ligero ---
	if Input.is_action_just_pressed("C") or Input.is_action_just_pressed("X_Ataque_Normal_Mando"):
		# Solo permitimos iniciar un ataque si el cooldown ha terminado
		if cooldown_timer_ataque_ligero.is_stopped():
			# Si el combo timer no está corriendo, es el inicio del combo.
			if combo_timer_ataque_ligero.is_stopped():
				ultimo_ataque = "Ligero_1"
			else:
				# Si el combo sigue activo, avanzamos en la secuencia
				if ultimo_ataque == "Ligero_1":
					ultimo_ataque = "Ligero_2"
				else:
					ultimo_ataque = "Ligero_1"
			
			estado_actual = Estado.ATAQUE_LIGERO
			EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_NORMAL")
			# Arrancamos ambos timers:
			cooldown_timer_ataque_ligero.start()   # Evita disparar otro ataque hasta que el cooldown expire.
			combo_timer_ataque_ligero.start()      # Reinicia el tiempo del combo para encadenar el siguiente ataque.
			
	# --- Ataque Fuerte Dash ---
	if Input.is_action_just_pressed("X") or Input.is_action_just_pressed("Y_Ataque_Fuerte_Mando"):
		if cooldown_dash_ataque.is_stopped():
			estado_actual = Estado.ATAQUE_FUERTE_DASH
			EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_FUERTE")
			cooldown_dash_ataque.start()
			# Aplicamos un impulso en la dirección que mira el personaje
			deslizarse = Vector2(direccion_num * deslizarse_strength, 0)
	
	# --- Iniciar dash solo si el cooldown ha terminado ---
	if Input.is_action_just_pressed("Barra_de_Espacio") or Input.is_action_just_pressed("Z") :
		if cooldown_dash.is_stopped():
			estado_actual = Estado.DASH
			# Reiniciamos la fuerza inicial del dash
			deslizarse = Vector2(direccion_num * deslizarse_strength, 0)
			# Arrancamos el cooldown para evitar reactivar dash inmediatamente.
			cooldown_dash.start()
	
	# Salto: si estamos en el suelo y se pulsa salto.
	if is_on_floor() and (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("A_Saltar_Mando")):
		velocity.y = -EstadisticasPlayer.FUERZA_SALTO
		estado_actual = Estado.SALTAR

	# --- APLICAR MOVIMIENTO ---
	velocity.x = input_vector.x * EstadisticasPlayer.velocidad
	velocity.y += GRAVEDAD * delta

	# Lógica de DASH y ATAQUE_FUERTE_DASH
	if estado_actual == Estado.DASH or estado_actual == Estado.ATAQUE_FUERTE_DASH:
		deslizarse = deslizarse.move_toward(Vector2.ZERO, deslizarse_friction * delta)
		if deslizarse.length() < 1:
			if is_on_floor():
				estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
			else:
				estado_actual = Estado.SALTAR
		velocity.x = deslizarse.x

	# Implementación de "jump cutting":
	if velocity.y < 0 and not (Input.is_action_pressed("ui_up") or Input.is_action_pressed("A_Saltar_Mando")):
		velocity.y = 0
	
	velocity += knockback
	
	move_and_slide()

	knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)

	# --- CAMBIO DE ESTADO TRAS MOVER ---
	if is_on_floor():
		if estado_actual == Estado.SALTAR:
			estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
		else:
			# Mientras no se esté atacando o muerto, actualizamos el estado según el movimiento.
			if estado_actual not in [Estado.ATAQUE_LIGERO, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE_DASH, Estado.DASH, Estado.DESLIZARSE]:
				estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
	else:
		# En el aire, si no se está realizando una acción especial, forzamos el estado de salto.
		if estado_actual not in [Estado.ATAQUE_LIGERO, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE_DASH, Estado.DASH, Estado.DESLIZARSE]:
			estado_actual = Estado.SALTAR

	# --- ACTUALIZAR EL ESTADO EN EL ANIMATION TREE ---
	_update_animation()


func _update_animation() -> void:
	var nueva_animacion: String = ""
	match estado_actual:
		Estado.IDLE:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Idle" 
		Estado.CORRER:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Correr"
		Estado.DASH:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Dash"
		Estado.DESLIZARSE:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Deslizarse"
		Estado.SALTAR:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Saltar"
		Estado.ATAQUE_LIGERO:
			if ultimo_ataque == "Ligero_1":
				sprite_2d.flip_h = (direccion_num == -1)
				nueva_animacion = "Ataque_Ligero_1"
			elif ultimo_ataque == "Ligero_2":
				sprite_2d.flip_h = (direccion_num == -1)
				nueva_animacion = "Ataque_Ligero_2"
		Estado.ATAQUE_FUERTE_DASH:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Ataque_Fuerte_Dash"
		Estado.HERIDO:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Herido"
		Estado.MUERTO:
			sprite_2d.flip_h = (direccion_num == -1)
			nueva_animacion = "Muerto"

	animation_player.play(nueva_animacion)


func _on_animation_finished(anim_name: String) -> void:
	# Manejar estados, al terminar animaciones sin loop
	if is_on_floor():
		estado_actual = Estado.CORRER if (Input.get_action_strength("ui_right") or Input.get_action_strength("ui_left")) else Estado.IDLE
	else:
		estado_actual = Estado.SALTAR


func _on_eliminar_player():
	# Find and remove any boss instances before changing scenes
	var bosses = get_tree().get_nodes_in_group("bosses")
	for boss in bosses:
		boss.queue_free()
		
	get_tree().change_scene_to_file("res://Cosas_Menus/Menu_Game_Over/menu_game_over.tscn")
	queue_free()

# --------------------
# Lógica de daño
# --------------------

# Función para obtener el daño del ataque según su tipo, incluyendo posibilidad de golpe crítico
func get_attack_damage(attack_type: String) -> int:
	var multiplicador: float = 1.0
	match attack_type:
		"ATAQUE_NORMAL":
			multiplicador = EstadisticasPlayer.MULTIPLICADOR_ATAQUE_NORMAL
		"ATAQUE_FUERTE":
			multiplicador = EstadisticasPlayer.MULTIPLICADOR_ATAQUE_FUERTE
		_:
			multiplicador = 1.0

	var damage: float = EstadisticasPlayer.base_damage * multiplicador * EstadisticasPlayer.Buffo_De_Daño_Player
	
	# Comprobamos si se produce un golpe crítico
	if randf() < EstadisticasPlayer.Probabilidad_Critico:
		damage *= EstadisticasPlayer.Daño_Critico
	
	return int(damage)

func _on_area_ataque_area_entered(area: Area2D) -> void:
	print("player algo golpeado detectó un area:", area)
	# Al atacar, se intenta hacer daño al enemigo.
	var objetivo = area
	while objetivo and not objetivo.has_method("recibir_daño"):
		objetivo = objetivo.get_parent()
	if objetivo:
		objetivo.call_deferred("recibir_daño", EstadisticasPlayer.daño_de_ataque)


func _on_area_herido_area_entered(area: Area2D) -> void:
	var atacante = area
	var daño_Recibido: int = 0
	while atacante and not atacante.has_method("hacer_daño"):
		atacante = atacante.get_parent()
		
	if atacante and atacante.has_method("hacer_daño"):
		daño_Recibido = atacante.hacer_daño() 
		# Usamos el método en lugar de acceder a la variable
	var knockback_direction: Vector2 = (global_position - area.global_position)
	knockback_direction.y = 0
	recibir_daño(daño_Recibido, knockback_direction)


func recibir_daño(daño_Recibido: int, direccion: Vector2) -> void:
	# Si ya está muerto, no se procesa más daño.
	if estado_actual == Estado.MUERTO:
		return
	
	EstadisticasPlayer.vida_actual_Player = max(EstadisticasPlayer.vida_actual_Player - daño_Recibido, 0)
	print("Player recibio daño: ", daño_Recibido, "Vida actual:", EstadisticasPlayer.vida_actual_Player)
	
	if EstadisticasPlayer.vida_actual_Player == 0:
		estado_actual = Estado.MUERTO
	else:
		estado_actual = Estado.HERIDO
		knockback = direccion.normalized() * knockback_strength


func _on_combo_timer_ataque_ligero_timeout() -> void:
	ultimo_ataque = ""
