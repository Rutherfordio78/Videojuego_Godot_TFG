extends CharacterBody2D

# Variables Globales
var GRAVEDAD = Global.GRAVEDAD

# Variable Caerse del mapa
var ultimo_suelo 

# Dirección del personaje (puedes usar esto para hacer flip en el Sprite).
var direccion_num: int = 1

# Referencia al AnimationTree y al controlador de estados.
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer
@onready var punto_lanzar: Marker2D = $Punto_Lanzar
@onready var menu_pausar_juego: Control = $Menu_Pausar_Juego

var shuriken_derecha = preload("res://Cosas_Personajes/Samurai/shuriken_derecha.tscn")
var shuriken_izquierda = preload("res://Cosas_Personajes/Samurai/shuriken_izquierda.tscn")

# --------------------
# Variables para Knockback
# --------------------
var knockback: Vector2 = Vector2.ZERO
var knockback_strength: float = 200.0  # Ajusta según la fuerza deseada
var knockback_friction: float = 300.0  # Velocidad a la que se reduce el knockback


# Definimos los estados posibles para el jugador.
enum Estado {
	IDLE,
	CORRER,
	SALTAR,
	ATACAR,
	ATAQUE_FUERTE,
	HERIDO,
	MUERTO
}

var estado_actual: Estado = Estado.IDLE

var saltos_disponibles: int = 2
var saltos_maximos: int = 2


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
		$Punto_Lanzar.position = Vector2(36, 8)
		$"Boxes_Daño/Hurt_Box/Colision_Ataque".position = Vector2(36, 0)
		$Animaciones/Sprite2D.flip_h = false
		
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("Moverse_Izquierda_Mando"):
		input_vector.x -= 1
		direccion_num = -1
		$Punto_Lanzar.position = Vector2(-36, 8)
		$"Boxes_Daño/Hurt_Box/Colision_Ataque".position = Vector2(-36, 0)
		$Animaciones/Sprite2D.flip_h = true
		

	# Ataque.
	# Al presionar los botones de ataque:
	if Input.is_action_just_pressed("C") or Input.is_action_just_pressed("X_Ataque_Normal_Mando"):
		estado_actual = Estado.ATACAR
		EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_NORMAL")
	
	if EstadisticasPlayer.municion > 0:
		if Input.is_action_just_pressed("X") or Input.is_action_just_pressed("Y_Ataque_Fuerte_Mando"):
			estado_actual = Estado.ATAQUE_FUERTE
			EstadisticasPlayer.daño_de_ataque_fuerte = get_attack_damage("ATAQUE_FUERTE")

	# Salto: implementación de doble salto
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("A_Saltar_Mando"):
		if is_on_floor():
			# Primer salto desde el suelo
			velocity.y = -EstadisticasPlayer.FUERZA_SALTO
			estado_actual = Estado.SALTAR
			saltos_disponibles = saltos_maximos - 1
		elif saltos_disponibles > 0:
			# Salto en el aire (doble salto)
			velocity.y = -EstadisticasPlayer.FUERZA_SALTO * 0.8  # Un poco menos potente
			estado_actual = Estado.SALTAR
			saltos_disponibles -= 1

	# --- APLICAR MOVIMIENTO ---
	velocity.x = input_vector.x * EstadisticasPlayer.velocidad
	velocity.y += GRAVEDAD * delta

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
		# Resetear saltos disponibles al tocar el suelo
		saltos_disponibles = saltos_maximos
		
		if estado_actual == Estado.SALTAR:
			estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
		else:
			# Mientras no se esté atacando, defendiendo o muerto, actualizamos el estado según el movimiento.
			if estado_actual not in [Estado.ATACAR, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE]:
				estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
	else:
		# En el aire, si no se está realizando una acción especial, forzamos el estado de salto.
		if estado_actual not in [Estado.ATACAR, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE]:
			estado_actual = Estado.SALTAR

	# --- ACTUALIZAR EL ESTADO EN EL ANIMATION TREE ---
	_update_animation()


func _update_animation() -> void:
	var nueva_animacion: String = ""
	match estado_actual:
		Estado.IDLE:
			nueva_animacion = "Idle"
		Estado.CORRER:
			nueva_animacion = "Correr"
		Estado.SALTAR:
			nueva_animacion = "Saltar"
		Estado.ATACAR:
			nueva_animacion = "Ataque_1"
		Estado.ATAQUE_FUERTE:
			nueva_animacion = "Ataque_2"
		Estado.HERIDO:
			nueva_animacion = "Herido"
		Estado.MUERTO:
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


func _lanzar_Suriken():
	if direccion_num == 1 :
		var bullet = shuriken_derecha.instantiate()
		bullet.global_position = punto_lanzar.global_position
		get_tree().current_scene.add_child(bullet)
		EstadisticasPlayer.municion = max(EstadisticasPlayer.municion - 1, 0)
	else:
		var bullet = shuriken_izquierda.instantiate()
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


func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("player algo golpeado detectó un area:", area)
	# Al atacar, se intenta hacer daño al enemigo.
	var objetivo = area
	while objetivo and not objetivo.has_method("recibir_daño"):
		objetivo = objetivo.get_parent()
	if objetivo:
		objetivo.call_deferred("recibir_daño", EstadisticasPlayer.daño_de_ataque)


func _on_hit_box_area_entered(area: Area2D) -> void:
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
