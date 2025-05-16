extends CharacterBody2D

# ---------------------------------------------------
# ESTADOS DEL BOSS
# ---------------------------------------------------
enum BossState {
	APARICION,
	RONDAR,
	ATAQUE_1,
	ATAQUE_2,
	SKILL_1,
	INVOCAR,
	MUERTE
}

# ---------------------------------------------------
# VARIABLES GLOBALES Y CONSTANTES
# ---------------------------------------------------
var tiempo_fade: float = 1.0

var current_state: BossState = BossState.APARICION
var last_attack_state: BossState = BossState.ATAQUE_2  # Inicializamos con cualquier valor

var mirando_derecha: bool = true
var atacando = false
var posicion_inicial: Vector2
var target_position: Vector2 = Vector2.ZERO

# Configuración del combate
var rango_ataque: float = 40.0
var daño: int
var arena_width: float = 1000.0
var arena_center_x: float = 400.0

# Variables para el ataque 2 
var altura_y: float = 0
var opcion: int = 550
var proceso_ataque_2_empezado = false
var attack2_initialized: bool = false
var teletrasporte_finalizado = false

# Preloads y nodos de invocación
var punto

var sombra_scene = preload("res://Cosas_Enemigos/Rey_Sombrio_Boss/mini_sombra.tscn")  # Ejemplo temporal

@onready var pos_summon_1: Marker2D = $Markers_Invocaciones/Pos_Summon_1
@onready var pos_summon_2: Marker2D = $Markers_Invocaciones/Pos_Summon_2
@onready var pos_summon_3: Marker2D = $Markers_Invocaciones/Pos_Summon_3
@onready var pos_summon_4: Marker2D = $Markers_Invocaciones/Pos_Summon_4
@onready var pos_summon_5: Marker2D = $Markers_Invocaciones/Pos_Summon_5
@onready var pos_summon_6: Marker2D = $Markers_Invocaciones/Pos_Summon_6
@onready var pos_summon_7: Marker2D = $Markers_Invocaciones/Pos_Summon_7
@onready var pos_summon_8: Marker2D = $Markers_Invocaciones/Pos_Summon_8
@onready var pos_summon_9: Marker2D = $Markers_Invocaciones/Pos_Summon_9
@onready var pos_summon_10: Marker2D = $Markers_Invocaciones/Pos_Summon_10
@onready var pos_summon_11: Marker2D = $Markers_Invocaciones/Pos_Summon_11
@onready var pos_summon_12: Marker2D = $Markers_Invocaciones/Pos_Summon_12

var puntos_invocacion

var min_sombras_invocar: int = 2
var max_sombras_invocar: int = 6

# Velocidad y movimiento
var speed: float = 150.0

# Vida del boss
var vida: int = 500

# Bandera para indicar que el boss está muerto
var is_dead: bool = false   

# Control de efecto de daño
var flash_duration: float = 0.3
var flash_timer: float = 0.0
var tiempo_espera: float = 0.5
var timer_espera: float = 0.0

# ---------------------------------------------------
# REFERENCIAS A NODOS (TIMERS, ANIMACIONES, SPRITES)
# ---------------------------------------------------
@onready var timer_ataque_2 = $Timers/Tiempo_Entre_Ataques_2
@onready var timer_rondar   = $Timers/Tiempo_Entre_Rondar
@onready var reasignar_target: Timer = $Timers/Reasignar_Target

@onready var anim_player = $Animaciones/AnimationPlayer
@onready var animation_player_tp: AnimationPlayer = $Animacion_TP/AnimationPlayer_TP

@onready var sprite_2d: Sprite2D = $Animaciones/Sprite2D
@onready var sprite_tp: Sprite2D = $Animacion_TP/Sprite_TP

# ---------------------------------------------------
# MÉTODOS DEL CICLO DE VIDA
# ---------------------------------------------------
func _ready() -> void:
	# Guardamos la posición de inicio y activamos el estado de aparición
	posicion_inicial = global_position
	set_state(BossState.APARICION)

	puntos_invocacion = [
		pos_summon_1,
		pos_summon_2,
		pos_summon_3,
		pos_summon_4,
		pos_summon_5,
		pos_summon_6,
		pos_summon_7,
		pos_summon_8,
		pos_summon_9,
		pos_summon_10,
		pos_summon_11,
		pos_summon_12,
	]

func _physics_process(delta: float) -> void:
	# Si el boss está muerto, solo procesa efectos y la animación de muerte
	if current_state == BossState.MUERTE:
		flash_timer -= delta
		if flash_timer <= 0:
			# Restaura el color normal
			sprite_2d.modulate = Color(1, 1, 1, 1)
			timer_espera -= delta
		# Evita que se procese otra lógica de estados
		move_and_slide()
		return

	match current_state:
		BossState.APARICION:
			# Aquí se podría agregar lógica de entrada o espera
			pass
		
		BossState.RONDAR:
			process_rondar(delta)
			if timer_rondar.is_stopped():
				timer_rondar.start()
		
		BossState.ATAQUE_1:
			process_ataque_1(delta)
		
		BossState.ATAQUE_2:
			process_ataque_2(delta)
		
		BossState.SKILL_1:
			process_skill_1(delta)
		
		BossState.INVOCAR:
			pass
		
		# El estado MUERTE se procesa al inicio para evitar sobrescrituras
			
	# Restaurar el color original tras el efecto de daño
	flash_timer -= delta
	if flash_timer <= 0:
		sprite_2d.modulate = Color(1, 1, 1, 1)
		timer_espera -= delta
	
	# Aplicar movimiento
	move_and_slide()

# ---------------------------------------------------
# GESTIÓN DE ESTADOS
# ---------------------------------------------------
func set_state(new_state: BossState) -> void:
	if is_dead and new_state != BossState.MUERTE:
		return
	# Si la vida es 0 o menor, forzamos el estado de MUERTE.
	if vida <= 0 and new_state != BossState.MUERTE:
		new_state = BossState.MUERTE
	
	current_state = new_state
	
	match current_state:
		BossState.APARICION:
			animation_player_tp.play("Teletransporte_Salir_Inicio_Combate")
		
		BossState.RONDAR:
			reproducir_animacion_idle()

		BossState.ATAQUE_1:
			teletransportarse_al_inicio()
			await get_tree().create_timer(0.8).timeout
		
		BossState.ATAQUE_2:
			teletransportarse_altura_player()
			await get_tree().create_timer(1.5).timeout
			timer_ataque_2.start()
		
		BossState.SKILL_1:
			teletransportarse_al_inicio()
			await get_tree().create_timer(0.8).timeout
		
		BossState.INVOCAR:
			teletransportarse_al_inicio()
			await get_tree().create_timer(0.8).timeout
			process_invocar()
		
		BossState.MUERTE:
			is_dead = true
			timer_ataque_2.stop()
			timer_rondar.stop()
			reasignar_target.stop()
			finish_ataque_1()
			finish_ataque_2()
			finish_invocar()
			finish_skill_1()
			velocity = Vector2.ZERO
			if mirando_derecha:
				anim_player.play("Muerte_Derecha")
			else:
				anim_player.play("Muerte_Izquierda")

# ---------------------------------------------------
# PROCESOS DE ESTADOS
# ---------------------------------------------------

func process_rondar(delta: float) -> void:
	if target_position == Vector2.ZERO:
		assign_random_target()
	
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	
	if velocity.x > 0:
		mirando_derecha = true
		anim_player.play("Idle_Derecha")
	elif velocity.x < 0:
		mirando_derecha = false
		anim_player.play("Idle_Izquierda")

func assign_random_target() -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	reasignar_target.start()
	var min_distance = 100.0
	var random_offset = Vector2(
		randf_range(-1000, 1000),
		randf_range(-1000, 1000)
	)
	var target = posicion_inicial + random_offset
	target.x = clamp(target.x, posicion_inicial.x - 590, posicion_inicial.x + 620)
	target.y = clamp(target.y, posicion_inicial.y - 100, posicion_inicial.y + 325)
	while global_position.distance_to(target) < min_distance:
		random_offset = Vector2(
			randf_range(-1000, 1000),
			randf_range(-1000, 1000)
		)
		target = posicion_inicial + random_offset
		target.x = clamp(target.x, posicion_inicial.x - 590, posicion_inicial.x + 620)
		target.y = clamp(target.y, posicion_inicial.y - 100, posicion_inicial.y + 325)
	
	target_position = target

func process_ataque_1(delta: float) -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	daño = 30
	var direction_to_player = EstadisticasPlayer.posicion_Player - global_position
	if not atacando:
		if direction_to_player.x >= 0:
			mirando_derecha = true
			anim_player.play("Idle_Derecha")
		else:
			mirando_derecha = false
			anim_player.play("Idle_Izquierda")
	
	if direction_to_player.length() < rango_ataque:
		atacando = true
		if mirando_derecha:
			anim_player.play("Ataque_1_Derecha")
		else:
			anim_player.play("Ataque_1_Izquierda")
	else:
		velocity = direction_to_player.normalized() * 200
		

func finish_ataque_1() -> void:
	atacando = false
	set_state(BossState.RONDAR)
	last_attack_state = BossState.ATAQUE_1

func process_ataque_2(delta: float) -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	if not teletrasporte_finalizado:
		return
	
	daño = 20
	
	if not attack2_initialized:
		if opcion == 550:
			mirando_derecha = false
			anim_player.play("Ataque_2_Izquierda")
			velocity = Vector2(-300, 0)
		else:
			mirando_derecha = true
			anim_player.play("Ataque_2_Derecha")
			velocity = Vector2(300, 0)
		attack2_initialized = true

func finish_ataque_2() -> void:
	$"Boxes_Daño/Area_Ataque/Colision_Ataque".disabled = true
	target_position = Vector2.ZERO
	attack2_initialized = false
	teletrasporte_finalizado = false
	set_state(BossState.RONDAR)
	last_attack_state = BossState.ATAQUE_2

func process_skill_1(delta: float) -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	daño = 25
	var direction_to_player = EstadisticasPlayer.posicion_Player - global_position
	if not atacando:
		if direction_to_player.x >= 0:
			mirando_derecha = true
			anim_player.play("Idle_Derecha")
		else:
			mirando_derecha = false
			anim_player.play("Idle_Izquierda")
	
	if direction_to_player.length() < rango_ataque:
		atacando = true
		if mirando_derecha:
			anim_player.play("Skill_1_Derecha")
		else:
			anim_player.play("Skill_1_Izquierda")
	else:
		velocity = direction_to_player.normalized() * 200

func finish_skill_1() -> void:
	atacando = false
	set_state(BossState.RONDAR)
	last_attack_state = BossState.SKILL_1

func process_invocar() -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	print("estado invocar")
	velocity = Vector2.ZERO
	var num_sombras = randi() % (max_sombras_invocar - min_sombras_invocar + 1) + min_sombras_invocar

	for i in range(num_sombras):
		punto = puntos_invocacion.pick_random()

		if punto == pos_summon_7 or punto == pos_summon_8 or punto == pos_summon_9 or punto == pos_summon_10 or punto == pos_summon_11 or punto == pos_summon_12:
			anim_player.play("Invocar_Derecha")
		else:
			anim_player.play("Invocar_Izquierda")

		await get_tree().create_timer(1).timeout
		
	finish_invocar()

func _invocar_sombra() -> void:
	var sombra = sombra_scene.instantiate()
	get_parent().add_child(sombra)
	sombra.global_position = punto.global_position

func finish_invocar() -> void:
	set_state(BossState.RONDAR)
	last_attack_state = BossState.INVOCAR

func choose_random_attack() -> BossState:
	var posibles = [BossState.ATAQUE_1, BossState.ATAQUE_2, BossState.SKILL_1, BossState.INVOCAR]
	posibles.erase(last_attack_state)
	var index = randi() % posibles.size()
	return posibles[index]

# ---------------------------------------------------
# HANDLERS DE TIMEOUT DE LOS TIMERS
# ---------------------------------------------------

func _on_tiempo_entre_ataques_2_timeout() -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	finish_ataque_2()

func _on_reasignar_target_timeout() -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	assign_random_target()

func _on_tiempo_entre_rondar_timeout() -> void:
	if is_dead:
		set_state(BossState.MUERTE)
		return
	var next_attack = choose_random_attack()
	set_state(next_attack)

# ---------------------------------------------------
# DAÑO Y MUERTE
# ---------------------------------------------------
func recibir_daño(cantidad: int) -> void:
	# Si ya está muerto, no procesamos más daño.
	if is_dead:
		set_state(BossState.MUERTE)
		return
	vida -= cantidad
	_flash_red()
	$Herido.play()
	if vida <= 0:
		set_state(BossState.MUERTE)

func _flash_red() -> void:
	sprite_2d.modulate = Color(1, 0, 0, 1)
	flash_timer = flash_duration
	timer_espera = tiempo_espera

func _on_eliminar_boss() -> void:
	Global.BOSS_VIVO = false
	queue_free()
	
func hacer_daño() -> int:
	return daño

# ---------------------------------------------------
# FUNCIONES AUXILIARES (TELETRANSPORTE Y CAMBIO DE POSICIÓN)
# ---------------------------------------------------
func teletransportarse_al_inicio() -> void:
	animation_player_tp.play("Teletransporte_Entrar")

func teletransportarse_altura_player() -> void:
	animation_player_tp.play("Teletransporte_Entrar_Altura_Player")

func cambiar_posicion() -> void:
	global_position = posicion_inicial
	animation_player_tp.play("Teletransporte_Salir")

func cambiar_posicion_altura_player() -> void:
	var opciones = [550, -550]
	opcion = opciones.pick_random()
	print("opcion: ", opcion)
	altura_y = EstadisticasPlayer.posicion_Player.y
	print("altura y: ", altura_y)
	var random_x = posicion_inicial.x + opcion
	global_position = Vector2(random_x, altura_y)
	animation_player_tp.play("Teletransporte_Salir")
	teletrasporte_finalizado = true

func reproducir_animacion_idle() -> void:
	if mirando_derecha:
		anim_player.play("Idle_Derecha")
	else:
		anim_player.play("Idle_Izquierda")
		
func iniciar_combate():
	set_state(BossState.RONDAR)
