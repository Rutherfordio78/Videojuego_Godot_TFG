extends RigidBody2D

@onready var sprite = $animaciones2/AnimationPlayer
@onready var raycast = $RayCast2D2
@onready var sonido = $AudioStreamPlayer2D2
@onready var marker = $Marker2D2

# Pre-carga de la escena de la bala
var bullet_scene = preload("res://Cosas_Enemigos/Trampa_Torreta/bala_de_madera_izquierda.tscn")
var trozo_1 = preload("res://Cosas_Enemigos/Trampa_Torreta/trozo_2.tscn")
var trozo_2 = preload("res://Cosas_Enemigos/Trampa_Torreta/trozo_3.tscn")
var trozo_3 = preload("res://Cosas_Enemigos/Trampa_Torreta/trozo_4.tscn")

# Variables para controlar el disparo (cooldown)
var can_shoot = true
var shoot_cooldown = 3.0  # Tiempo entre disparos en segundos
var shoot_timer = 0.0

# Vida de la torreta
var vida = 20

# Definimos los estados de la torreta
enum TURRET_STATE {
	IDLE,
	DISPARAR,
	HERIDO,
	MUERTO
}

var estado = TURRET_STATE.IDLE

# Función para aplicar la gravedad manualmente usando la constante Global.GRAVEDAD
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity.y += Global.GRAVEDAD * state.step

func _ready() -> void: 
	# Si quieres hacer algo al inicio (ej. reproducir anim Idle):
	sprite.play("Idle")

func _physics_process(delta: float) -> void:
	# Manejamos el cambio de estados y la lógica de la torreta
	match estado:
		TURRET_STATE.IDLE:
			# Aseguramos que la animación Idle esté activa
			if sprite.current_animation != "Idle":
				sprite.play("Idle")
			
			# Si el RayCast detecta un cuerpo (por ejemplo el jugador),
			# cambiamos a estado Disparar
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				# Ajusta la forma de detectar si es el Player
				# (ej. por nombre, por grupo, etc.)
				if collider and collider.is_in_group("player"):
					estado = TURRET_STATE.DISPARAR

		TURRET_STATE.DISPARAR:
			# Reproducir la animación de disparo
			if sprite.current_animation != "Disparar":
				sprite.play("Disparar")
			
			# Dispara si puede
			if can_shoot:
				disparar()

			# Opcional: si ya no detecta al jugador, volver a Idle
			if not raycast.is_colliding():
				estado = TURRET_STATE.IDLE

		TURRET_STATE.HERIDO:
			# Reproducir la animación de herido
			if sprite.current_animation != "Herido":
				sprite.play("Herido")
			
			# Después de un momento, podrías volver a Idle
			# o quedarte un rato en "Herido"
			# Aquí, por ejemplo, lo dejamos volver a Idle instantáneamente
			estado = TURRET_STATE.IDLE

		TURRET_STATE.MUERTO:
			# No hay animación de muerte, sino que invocamos los trozos
			romper_torreta()
			var dropped_item = Global.Dropear_Items_Normales()
				# Opcional: se posiciona el ítem donde estaba el enemigo
			dropped_item.global_position = global_position
				# Se agrega el ítem a la escena actual
			get_tree().current_scene.add_child(dropped_item)
			queue_free()
			return  # Evitamos seguir ejecutando el resto del código

	# Manejo del cooldown de disparo
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			can_shoot = true
			shoot_timer = 0.0

# Lógica de disparo
func disparar() -> void:
	# Instanciar la bala
	var bullet = bullet_scene.instantiate()
	bullet.global_position = marker.global_position
	get_tree().current_scene.add_child(bullet)
	
	# Reproducir sonido (si lo deseas)
	if sonido:
		sonido.play()

	# No se puede disparar de inmediato otra vez
	can_shoot = false

# Función para recibir daño
func recibir_daño(cantidad: int) -> void:
	vida -= cantidad
	if vida <= 0:
		vida = 0
		estado = TURRET_STATE.MUERTO
	else:
		estado = TURRET_STATE.HERIDO

# Invocar trozos rotos de la torreta
func romper_torreta() -> void:
	var t1 = trozo_1.instantiate()
	t1.global_position = global_position
	get_tree().current_scene.add_child(t1)

	var t2 = trozo_2.instantiate()
	t2.global_position = global_position
	get_tree().current_scene.add_child(t2)

	var t3 = trozo_3.instantiate()
	t3.global_position = global_position
	get_tree().current_scene.add_child(t3)

	# Aquí se destruye la torreta en el mismo ciclo de _physics_process
	# Se hace en TURRET_STATE.MUERTO
