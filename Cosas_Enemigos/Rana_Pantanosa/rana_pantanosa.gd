extends CharacterBody2D

enum State {
	RUN,
	JUMP,
	HURT,
	DEAD
}

@export var velocidad: float = 100.0          # Velocidad horizontal
@export var fuerza_salto: float = -350.0      # Fuerza de salto (negativo hacia arriba)
var GRAVEDAD = Global.GRAVEDAD                # Gravedad (afecta el eje y)
@export var rango_movimiento: float = 100.0     # Distancia máx. desde el centro
@export var vida_Enemigo: int = 50              # Puntos de vida de la rana

var estado_actual: State = State.RUN
var posicion_centro: Vector2
var direccion: int = 1      # 1 = derecha, -1 = izquierda

var flash_duration: float = 0.3
var flash_timer: float = 0.0
var fade_speed: float = 1.0
var tiempo_espera: float = 0.5
var timer_espera: float = 0.0
var original_modulate: Color
var daño_de_ataque: int = 10

# Variables para la anticipación del salto
var jump_delay_time: float = 0.5
var jump_timer: float = 0.0
var jump_applied: bool = false

@onready var anim_player: AnimationPlayer = $Animaciones/AnimationPlayer
@onready var sprite: Sprite2D = $Animaciones/Sprite2D
@onready var boxes_daño = $Boxes_Daño

func _ready() -> void:
	randomize()
	posicion_centro = global_position
	original_modulate = sprite.modulate
	boxes_daño.connect("Algo_Golpeado", Callable(self, "_on_Algo_Golpeado"))
	boxes_daño.connect("Golpe_Recibido", Callable(self, "_on_Golpe_Recibido"))

func _physics_process(delta: float) -> void:
	if estado_actual != State.DEAD and not is_on_floor():
		velocity.y += GRAVEDAD * delta

	match estado_actual:
		State.RUN:
			_process_run(delta)
		State.JUMP:
			_process_jump(delta)
		State.HURT:
			_process_hurt(delta)
		State.DEAD:
			_process_dead(delta)

	move_and_slide()
	_update_animation()

func _process_run(delta: float) -> void:
	var max_x = posicion_centro.x + rango_movimiento
	var min_x = posicion_centro.x - rango_movimiento

	# En RUN, se ajusta la dirección según la posición actual
	if global_position.x > max_x:
		direccion = -1
	elif global_position.x < min_x:
		direccion = 1

	velocity.x = direccion * velocidad

	# Ocasionalmente se dispara el salto
	if randi() % 200 < 5:
		estado_actual = State.JUMP
		jump_timer = jump_delay_time   # Establece el retraso para el salto
		jump_applied = false

func _process_jump(delta: float) -> void:
	# Durante el estado JUMP, primero se espera el retraso para que se inicie la animación
	if not jump_applied:
		if jump_timer > 0:
			jump_timer -= delta
		else:
			velocity.y = fuerza_salto   # Aplica la fuerza del salto
			jump_applied = true

	# Una vez aplicado el salto, al tocar el suelo se vuelve a RUN
	if is_on_floor() and jump_applied and velocity.y >= 0:
		estado_actual = State.RUN

func _process_hurt(delta: float) -> void:
	velocity.x = 0

	if vida_Enemigo <= 0:
		estado_actual = State.DEAD
		return

	if flash_timer > 0:
		flash_timer -= delta
	else:
		if timer_espera > 0:
			timer_espera -= delta
		else:
			# Permite recibir nuevos golpes y vuelve a RUN
			sprite.modulate = original_modulate
			estado_actual = State.RUN

func _process_dead(delta: float) -> void:
	$"Boxes_Daño/Hurt_Box/Colision_Ataque".disabled = true
	velocity = Vector2.ZERO
	var current_color = sprite.modulate
	current_color.a -= fade_speed * delta
	sprite.modulate = current_color
	if current_color.a <= 0:
		var dropped_item = Global.Dropear_Items_Especiales()
		dropped_item.global_position = global_position
		# Se agrega el ítem a la escena actual
		get_tree().current_scene.add_child(dropped_item)
		queue_free()

func _update_animation() -> void:
	match estado_actual:
		State.RUN:
			if direccion > 0:
				anim_player.play("Correr_Derecha")
			else:
				anim_player.play("Correr_Izquierda")
		State.JUMP:
			if direccion > 0:
				anim_player.play("Ataque_Salto_Derecha")
			else:
				anim_player.play("Ataque_Salto_Izquierda")
		State.HURT:
			if direccion > 0:
				anim_player.play("Herido_Derecha")
			else:
				anim_player.play("Herido_Izquierda")
		State.DEAD:
			if direccion > 0:
				anim_player.play("Muerto_Derecha")
			else:
				anim_player.play("Muerto_Izquierda")


func hacer_daño():
	return daño_de_ataque

func recibir_daño(daño_Recibido: int) -> void:
	if estado_actual == State.DEAD:
		return
	vida_Enemigo = max(vida_Enemigo - daño_Recibido, 0)
	print("Rana recibió daño: ", daño_Recibido, " | Vida actual:", vida_Enemigo)
	if vida_Enemigo <= 0:
		estado_actual = State.DEAD
	else:
		estado_actual = State.HURT
		_flash_red()

func _flash_red() -> void:
	sprite.modulate = Color(1, 0, 0, 1)
	flash_timer = flash_duration
	timer_espera = tiempo_espera

func _on_animation_finished(anim_name: String) -> void:
	sprite.modulate = original_modulate
	if is_on_floor():
		estado_actual = State.RUN
