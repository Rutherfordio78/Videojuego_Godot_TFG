extends CharacterBody2D

# Variables Globales
var GRAVEDAD = Global.GRAVEDAD

# Variable Caerse del mapa
var ultimo_suelo 

# Dirección del personaje (puedes usar esto para hacer flip en el Sprite).
var direccion_num: int

# Referencia al AnimationTree y al controlador de estados.
@onready var animation_tree: AnimationTree = $Animaciones/AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer

# Variable para las Boxes de Recibir y hacer Daño
@onready var boxes_dano = $Boxes_Daño

# Definimos los estados posibles para el jugador.
enum Estado {
	IDLE,
	CORRER,
	SALTAR,
	ATAQUE_LIGERO_SUELO,
	ATAQUE_LIGERO_AEREO,
	ATAQUE_FUERTE,
	DEFENDER,
	HERIDO,
	MUERTO
}

var estado_actual: Estado = Estado.IDLE

# --------------------
# Variables para Knockback
# --------------------
var knockback: Vector2 = Vector2.ZERO
var knockback_strength: float = 200.0  # Ajusta según la fuerza deseada
var knockback_friction: float = 300.0  # Velocidad a la que se reduce el knockback

func _ready() -> void:
	# Activa el AnimationTree.
	animation_tree.active = true
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
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("Moverse_Izquierda_Mando"):
		input_vector.x -= 1
		direccion_num = -1

	# Ataque.
	# Al presionar los botones de ataque:
	if Input.is_action_just_pressed("C") or Input.is_action_just_pressed("X_Ataque_Normal_Mando"):
		if not is_on_floor():
			estado_actual = Estado.ATAQUE_LIGERO_AEREO
		else:
			estado_actual = Estado.ATAQUE_LIGERO_SUELO
			
		EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_NORMAL")
	
	if is_on_floor():
		if Input.is_action_just_pressed("X") or Input.is_action_just_pressed("Y_Ataque_Fuerte_Mando"):
			estado_actual = Estado.ATAQUE_FUERTE
			EstadisticasPlayer.daño_de_ataque = get_attack_damage("ATAQUE_FUERTE")

	# Defenderse.
	if Input.is_action_just_pressed("Z") or Input.is_action_just_pressed("B_Defenderse_Mando"):
		estado_actual = Estado.DEFENDER

	# Salto: si estamos en el suelo y se pulsa salto.
	if is_on_floor() and (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("A_Saltar_Mando")):
		velocity.y = -EstadisticasPlayer.FUERZA_SALTO
		estado_actual = Estado.SALTAR

	# --- APLICAR MOVIMIENTO ---
	velocity.x = input_vector.x * EstadisticasPlayer.velocidad
	velocity.y += GRAVEDAD * delta

	# Implementación de "jump cutting":
	# Si el jugador suelta el botón de salto y aún se está moviendo hacia arriba,
	# se corta la velocidad vertical para que no siga ganando altura.
	if velocity.y < 0 and not (Input.is_action_pressed("ui_up") or Input.is_action_pressed("A_Saltar_Mando")):
		velocity.y = 0

	# Sumamos el knockback a la velocidad
	velocity += knockback

	# Movemos al personaje sin parámetros en move_and_slide()
	move_and_slide()

	# Reducimos gradualmente el knockback
	knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)

	# --- CAMBIO DE ESTADO TRAS MOVER ---
	if is_on_floor():
		if estado_actual == Estado.SALTAR:
			estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
		else:
			# Mientras no se esté atacando, defendiendo o muerto, actualizamos el estado según el movimiento.
			if estado_actual not in [Estado.ATAQUE_LIGERO_SUELO, Estado.ATAQUE_LIGERO_AEREO, Estado.DEFENDER, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE]:
				estado_actual = Estado.CORRER if input_vector.x != 0 else Estado.IDLE
	else:
		# En el aire, si no se está realizando una acción especial, forzamos el estado de salto.
		if estado_actual not in [Estado.ATAQUE_LIGERO_SUELO, Estado.ATAQUE_LIGERO_AEREO, Estado.DEFENDER, Estado.MUERTO, Estado.HERIDO, Estado.ATAQUE_FUERTE]:
			estado_actual = Estado.SALTAR

	# --- ACTUALIZAR EL ESTADO EN EL ANIMATION TREE ---
	_update_animation()

func _update_animation() -> void:
	# Actualizar la dirección en el BlendSpace1D
	animation_tree.set("parameters/Idle/blend_position", direccion_num)
	animation_tree.set("parameters/Correr/blend_position", direccion_num)
	animation_tree.set("parameters/Saltar/blend_position", direccion_num)
	animation_tree.set("parameters/Ataque_1/blend_position", direccion_num)
	animation_tree.set("parameters/Ataque_2/blend_position", direccion_num)
	animation_tree.set("parameters/Ataque_3/blend_position", direccion_num)
	animation_tree.set("parameters/Defenderse/blend_position", direccion_num)
	animation_tree.set("parameters/Herido/blend_position", direccion_num)
	animation_tree.set("parameters/Muerte/blend_position", direccion_num)

	match estado_actual:
		Estado.IDLE:
			state_machine.travel("Idle")
		Estado.CORRER:
			state_machine.travel("Correr")
		Estado.SALTAR:
			state_machine.travel("Saltar")
		Estado.ATAQUE_LIGERO_SUELO:
			state_machine.travel("Ataque_1")
		Estado.ATAQUE_LIGERO_AEREO:
			state_machine.travel("Ataque_3")
		Estado.ATAQUE_FUERTE:
			state_machine.travel("Ataque_2")
		Estado.DEFENDER:
			state_machine.travel("Defenderse")
		Estado.HERIDO:
			state_machine.travel("Herido")
		Estado.MUERTO:
			state_machine.travel("Muerte")

func _on_animation_finished() -> void:
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

# Modificamos la función para recibir daño y aplicar knockback en lugar de teletransportar.
func recibir_daño(daño_Recibido: int, direccion: Vector2) -> void:
	# Si ya está muerto, no se procesa más daño.
	if estado_actual == Estado.MUERTO:
		return
	
	EstadisticasPlayer.vida_actual_Player = max(EstadisticasPlayer.vida_actual_Player - daño_Recibido, 0)
	print("Player recibió daño:", daño_Recibido, "Vida actual:", EstadisticasPlayer.vida_actual_Player)
	
	if EstadisticasPlayer.vida_actual_Player == 0:
		estado_actual = Estado.MUERTO
	else:
		estado_actual = Estado.HERIDO
		# En vez de teletransportar, aplicamos knockback.
		knockback = direccion.normalized() * knockback_strength


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
		daño_Recibido = atacante.hacer_daño()  # Usamos el método en lugar de acceder a la variable
	# Calculamos la dirección del golpe: del atacante hacia el player.
	var knockback_direction: Vector2 = (global_position - area.global_position)
	knockback_direction.y = 0
	recibir_daño(daño_Recibido, knockback_direction)
