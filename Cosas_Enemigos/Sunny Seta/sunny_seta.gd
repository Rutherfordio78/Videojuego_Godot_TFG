extends CharacterBody2D

# Definimos los estados del enemigo
enum Estado {
	IDLE,
	CORRER,
	HERIDO,
	MUERTE
}

# Variables exportadas (ajustables en el editor)
var vida_Enemigo: int = 50
var velocidad_patrulla: float = 100.0
var tiempo_espera: float = 0.5
var distancia_de_patrulla: float = 100.0  
var daño_de_ataque = 10

# Estado actual
var estado_actual: Estado = Estado.IDLE

# Variables para la patrulla
var posicion_central: Vector2
var puntos_patrulla: Array = []
var indice_patrulla: int = 0
var timer_espera: float = 0.0

# Variables para el efecto de daño
var flash_duration: float = 0.3   # Tiempo en estado HERIDO
var flash_timer: float = 0.0
var fade_speed: float = 1.0       # Velocidad de desvanecimiento en estado MUERTE
var original_modulate: Color

# Referencia al AnimatedSprite2D (con las animaciones "Idle" y "Correr")
@onready var animated_sprite: AnimatedSprite2D = $Animaciones/AnimatedSprite2D
# Referencia a las cajas de daño (se asume que siguen funcionando igual)
@onready var boxes_dano = $"Boxes_Daño"

@onready var efecto_sonido: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# Guardamos la posición inicial y definimos los puntos de patrulla
	posicion_central = global_position
	puntos_patrulla = [
		posicion_central + Vector2(-distancia_de_patrulla, 0),
		posicion_central,
		posicion_central + Vector2(distancia_de_patrulla, 0),
		posicion_central
	]
	indice_patrulla = 0
	
	estado_actual = Estado.IDLE
	timer_espera = tiempo_espera
	
	# Guardamos el color original del sprite
	original_modulate = animated_sprite.modulate
	
	# Iniciamos la animación en Idle
	animated_sprite.play("Idle")

func _physics_process(delta: float) -> void:
	match estado_actual:
		Estado.IDLE:
			velocity = Vector2.ZERO
			timer_espera -= delta
			if timer_espera <= 0:
				estado_actual = Estado.CORRER
				
		Estado.CORRER:
			var target_pos = puntos_patrulla[indice_patrulla]
			var distance_to_target = target_pos.x - global_position.x
			var step = velocidad_patrulla * delta
			var direction = 1 if distance_to_target > 0 else -1
			
			animated_sprite.flip_h = (direction < 0)

			if abs(step) >= abs(distance_to_target):
				# Llegamos al objetivo
				global_position.x = target_pos.x
				velocity.x = 0
				estado_actual = Estado.IDLE
				timer_espera = tiempo_espera
				indice_patrulla = (indice_patrulla + 1) % puntos_patrulla.size()
			else:
				velocity.x = direction * velocidad_patrulla
				move_and_slide()
				
		Estado.HERIDO:
			# Durante el estado de "herido" el sprite parpadea en rojo
			efecto_sonido.play()
			flash_timer -= delta
			if flash_timer <= 0:
				# Finaliza el efecto y se vuelve al estado Idle (o se podría retomar otra lógica)
				animated_sprite.modulate = original_modulate
				estado_actual = Estado.IDLE
				timer_espera = tiempo_espera
				
		Estado.MUERTE:
			$"Boxes_Daño/Hurt_Box/Area_Daño".disabled = true
			# Se desvanece el sprite reduciendo su alfa hasta desaparecer
			var current_color = animated_sprite.modulate
			current_color.a -= fade_speed * delta
			animated_sprite.modulate = current_color
			if current_color.a <= 0:
				# Se instancia el ítem dropeado usando la función global
				var dropped_item = Global.Dropear_Items_Normales()
				# Opcional: se posiciona el ítem donde estaba el enemigo
				dropped_item.global_position = global_position
				# Se agrega el ítem a la escena actual
				get_tree().current_scene.add_child(dropped_item)
				# Se elimina el enemigo
				queue_free()

				
	_update_animation()

func _update_animation() -> void:
	match estado_actual:
		Estado.IDLE:
			if animated_sprite.animation != "Idle":
				animated_sprite.play("Idle")
		Estado.CORRER:
			if animated_sprite.animation != "Correr":
				animated_sprite.play("Correr")
		# Para HERIDO y MUERTE se usan efectos de modulación, no se cambian animaciones


# --------------------
# Lógica de daño
# --------------------

func hacer_daño():
	return daño_de_ataque

func recibir_daño(daño_Recibido: int) -> void:
	efecto_sonido.play()
	# Evitar aplicar daño si ya está muerto.
	if estado_actual == Estado.MUERTE:
		return
	vida_Enemigo = max(vida_Enemigo - daño_Recibido, 0)
	print("seta recibio daño: ", daño_Recibido, "Vida actual:", vida_Enemigo)
	if vida_Enemigo == 0:
		estado_actual = Estado.MUERTE
		# Aquí podrías agregar efectos o reproducir un sonido de muerte.
	else:
		estado_actual = Estado.HERIDO
		_flash_red()

func _flash_red() -> void:
	# Activa un efecto visual de parpadeo en rojo.
	animated_sprite.modulate = Color(1, 0, 0, 1)
	flash_timer = flash_duration
