extends CharacterBody2D

# Variables Globales
var GRAVEDAD = Global.GRAVEDAD

# Variable Caerse del mapa
var ultimo_suelo 

var ultimo_ataque: String

# Dirección del personaje (puedes usar esto para hacer flip en el Sprite).
var direccion_num: int

# Referencia al AnimationTree y al controlador de estados.
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer
@onready var punto_lanzar: Marker2D = $Punto_Disparo
@onready var sprite_2d: Sprite2D = $Animaciones/Sprite2D
@onready var cooldown_timer: Timer = $Cooldown_Timer
@onready var combo_timer: Timer = $Combo_Timer
@onready var cooldown_dash: Timer = $Cooldown_DASH


var flecha_derecha = preload("res://Cosas_Personajes/Caperucita_Roja/flecha_derecha.tscn")
var flecha_izquierda = preload("res://Cosas_Personajes/Caperucita_Roja/flecha_izquierda.tscn")

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
	ATAQUE_NORMAL,
	ATAQUE_FUERTE,
	DISPARO_ARCO,
	DASH,
	HERIDO,
	MUERTO
}

var estado_actual: Estado = Estado.IDLE


func _ready() -> void:
	ultimo_suelo = global_position


func _physics_process(delta: float) -> void:
	
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
		$"Boxes_Daño/Area_Ataque/Colision_Ataque".position = Vector2(17, -1)
		$Punto_Disparo.position = Vector2(20, -2)
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("Moverse_Izquierda_Mando"):
		input_vector.x -= 1
		direccion_num = -1
		$"Boxes_Daño/Area_Ataque/Colision_Ataque".position = Vector2(-17, -1)
		$Punto_Disparo.position = Vector2(-20, -2)

	# --- Ataque Normal ---
	if Input.is_action_just_pressed("C") or Input.is_action_just_pressed("X_Ataque_Normal_Mando"):
		# Solo permitimos iniciar un ataque si el cooldown ha terminado
		if cooldown_timer.is_stopped():
			# Si el combo timer no está corriendo, es el inicio del combo.
			if combo_timer.is_stopped():
				ultimo_ataque = "Normal_1"
			else:
				# Si el combo sigue activo, avanzamos en la secuencia
				match ultimo_ataque:
					"Normal_1":
						ultimo_ataque = "Normal_2"
					"Normal_2":
						ultimo_ataque = "Normal_3"
					_:
						ultimo_ataque = "Normal_1"
			estado_actual = Estado.ATAQUE_NORMAL
			EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_NORMAL")
			# Arrancamos ambos timers:
			cooldown_timer.start()   # Evita disparar otro ataque hasta que el cooldown expire.
			combo_timer.start()      # Reinicia el tiempo del combo para encadenar el siguiente ataque.
			
	# --- Ataque Fuerte (solo en suelo) ---
	if is_on_floor():
		if Input.is_action_just_pressed("X") or Input.is_action_just_pressed("Y_Ataque_Fuerte_Mando"):
			if cooldown_timer.is_stopped():
				if combo_timer.is_stopped():
					ultimo_ataque = "Fuerte_1"
				else:
					match ultimo_ataque:
						"Fuerte_1":
							ultimo_ataque = "Fuerte_2"
						"Fuerte_2":
							ultimo_ataque = "Fuerte_3"
						_:
							ultimo_ataque = "Fuerte_1"
				estado_actual = Estado.ATAQUE_FUERTE
				EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_FUERTE")
				cooldown_timer.start()
				combo_timer.start()

	# Disparar Arco
	if EstadisticasPlayer.municion > 0:
		if Input.is_action_just_pressed("Z") or Input.is_action_just_pressed("B_Defenderse_Mando"):
			estado_actual = Estado.DISPARO_ARCO
			EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_NORMAL")
	
# --- Iniciar dash solo si el cooldown ha terminado ---
	if is_on_floor():
		if Input.is_action_just_pressed("Barra_de_Espacio") and cooldown_dash.is_stopped():
			estado_actual = Estado.DASH
			# Reiniciamos la fuerza inicial del dash
			deslizarse = Vector2(direccion_num * deslizarse_strength, 0)
			# Arrancamos el cooldown para evitar reactivar dash inmediatamente.
			cooldown_dash.start()


	
	# Salto: si estamos en el suelo y se pulsa salto.
	if is_on_floor() and Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("A_Saltar_Mando"):
		velocity.y = -EstadisticasPlayer.FUERZA_SALTO
		estado_actual = Estado.SALTAR

	# --- APLICAR MOVIMIENTO ---
	velocity.x = input_vector.x * EstadisticasPlayer.velocidad
	velocity.y += GRAVEDAD * delta

	# Lógica de DASH
	if estado_actual == Estado.DASH:
		# Como ya usamos is_action_just_pressed para activarlo,
		# no volvemos a reiniciar la fuerza aquí; solo aplicamos la fricción.
		deslizarse = deslizarse.move_toward(Vector2.ZERO, deslizarse_friction * delta)
		# Cuando la fuerza residual sea mínima, se finaliza el dash y se cambia el estado.
		if deslizarse.length() < 1:
			if is_on_floor():
				estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
			else:
				estado_actual = Estado.SALTAR
		# Se aplica la fuerza del dash en el eje X.
		velocity.x = deslizarse.x


	# Implementación de "jump cutting":
	# Si el jugador suelta el botón de salto y aún se está moviendo hacia arriba,
	# se corta la velocidad vertical para que no siga ganando altura.
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
			if estado_actual not in [Estado.ATAQUE_NORMAL, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE, Estado.DISPARO_ARCO, Estado.DASH]:
				estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
	else:
		# En el aire, si no se está realizando una acción especial, forzamos el estado de salto.
		if estado_actual not in [Estado.ATAQUE_NORMAL, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE, Estado.DISPARO_ARCO, Estado.DASH]:
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
			sprite_2d.flip_h = (direccion_num == 1)
			nueva_animacion = "Correr"
		Estado.DASH:
			sprite_2d.flip_h = (direccion_num == 1)
			nueva_animacion = "Deslizarse"
		Estado.SALTAR:
			sprite_2d.flip_h = (direccion_num == 1)
			nueva_animacion = "Saltar"
		Estado.ATAQUE_NORMAL:
			if ultimo_ataque == "Normal_1":
				sprite_2d.flip_h = (direccion_num == 1)
				nueva_animacion = "Ataque_Normal_1"
			elif ultimo_ataque == "Normal_2":
				sprite_2d.flip_h = (direccion_num == 1)
				nueva_animacion = "Ataque_Normal_2"
			elif ultimo_ataque == "Normal_3":
				sprite_2d.flip_h = (direccion_num == 1)
				nueva_animacion = "Ataque_Normal_3"
		Estado.ATAQUE_FUERTE:
			if ultimo_ataque == "Fuerte_1":
				sprite_2d.flip_h = (direccion_num == 1)
				nueva_animacion = "Ataque_Fuerte_1"
			elif ultimo_ataque == "Fuerte_2":
				sprite_2d.flip_h = (direccion_num == 1)
				nueva_animacion = "Ataque_Fuerte_2"
			elif ultimo_ataque == "Fuerte_3":
				sprite_2d.flip_h = (direccion_num == 1)
				nueva_animacion = "Ataque_Fuerte_3"
		Estado.DISPARO_ARCO:
			sprite_2d.flip_h = (direccion_num == 1)
			nueva_animacion = "Disparar_Arco"
		Estado.HERIDO:
			sprite_2d.flip_h = (direccion_num == 1)
			nueva_animacion = "Herido"
		Estado.MUERTO:
			sprite_2d.flip_h = (direccion_num == 1)
			nueva_animacion = "Muerte"

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


func _disparar_Flecha():
	if direccion_num == 1:
		var bullet = flecha_derecha.instantiate()
		bullet.global_position = punto_lanzar.global_position
		get_tree().current_scene.add_child(bullet)
		EstadisticasPlayer.municion = max(EstadisticasPlayer.municion - 1, 0)
	else:
		var bullet = flecha_izquierda.instantiate()
		bullet.global_position = punto_lanzar.global_position
		get_tree().current_scene.add_child(bullet)
		EstadisticasPlayer.municion = max(EstadisticasPlayer.municion - 1, 0)

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
		
	if atacante.has_method("hacer_daño"):
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


func _on_combo_timer_timeout() -> void:
	ultimo_ataque = ""
