extends CharacterBody2D

var vida_enemigo: int = 40
var daño_de_ataque: int = 10

enum Estado {
	OCULTO,
	ATAQUE,
	HERIDO,
	MUERTO,
}

var estado_actual: Estado = Estado.OCULTO

var puede_atacar = true

# Variables para el efecto de daño (flash rojo)
var flash_duration: float = 0.3  # Tiempo total en estado "flash"
var flash_timer: float = 0.0

# Velocidad de desvanecimiento en estado MUERTO
var fade_speed: float = 1.0

# Guardamos el color original del sprite
var original_modulate: Color

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Animaciones/Sprite2D
@onready var animation_player: AnimationPlayer = $Animaciones/AnimationPlayer

# Áreas de ataque y de recibir daño
@onready var area_ataque: Area2D = $"Boxes_Daño/Area_Ataque"
@onready var colision_ataque: CollisionShape2D = $"Boxes_Daño/Area_Ataque/Colision_Ataque"
@onready var area_herido: Area2D = $"Boxes_Daño/Area_Herido"
@onready var colision_herido: CollisionShape2D = $"Boxes_Daño/Area_Herido/Colision_Herido"

@onready var timer_ataque: Timer = $TimerAtaque
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	animation_player.play("Oculto")
	original_modulate = sprite_2d.modulate

func _physics_process(delta: float) -> void:
	
	match estado_actual:
		Estado.HERIDO:
			# Maneja el temporizador del flash rojo
			if flash_timer > 0:
				flash_timer -= delta
				if flash_timer <= 0:
					sprite_2d.modulate = original_modulate
					# Si el enemigo sigue vivo, vemos si estaba atacando o no
					if vida_enemigo > 0:
						# Si estaba en medio de un ataque, no lo interrumpimos;
						# pero aquí puede que sigas en ATAQUE (si la animación no ha acabado)
						# o que ya estés en COOLDOWN (si la animación terminó).
						# En caso de duda, lo dejamos como está.
						pass

		Estado.MUERTO:
			# Desvanecemos poco a poco hasta desaparecer
			var mod = sprite_2d.modulate
			mod.a = max(mod.a - fade_speed * delta, 0)
			sprite_2d.modulate = mod
			if mod.a <= 0:
				var dropped_item = Global.Dropear_Items_Normales()
				dropped_item.global_position = global_position
				get_tree().current_scene.add_child(dropped_item)
				queue_free()


func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and puede_atacar == true: 
		print("Area entered")# Ajusta a la comprobación que uses para tu player
		cambiar_estado(Estado.ATAQUE)

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if estado_actual != Estado.MUERTO:
		cambiar_estado(Estado.OCULTO)
		timer_ataque.start()  # Arrancamos el cooldown


func _on_timer_ataque_timeout() -> void:
	puede_atacar = true

func cambiar_estado(nuevo_estado: Estado) -> void:
	if estado_actual == nuevo_estado:
		return

	estado_actual = nuevo_estado

	match estado_actual:
		Estado.OCULTO:
			animation_player.play("Oculto")

		Estado.ATAQUE:
			puede_atacar = false
			# Inicia la animación de ataque
			animation_player.play("Ataque")
			# No iniciamos el timer aquí, porque el ataque termina con la animación

		Estado.HERIDO:
			# Solo mostramos el flash rojo; no detenemos la animación de ataque si está en curso
			_flash_red()

		Estado.MUERTO:
			timer_ataque.stop()


func recibir_daño(daño: int) -> void:
	if estado_actual == Estado.MUERTO:
		return

	vida_enemigo = max(vida_enemigo - daño, 0)
	print("Enemigo recibió daño:", daño, "Vida actual:", vida_enemigo)

	if vida_enemigo <= 0:
		cambiar_estado(Estado.MUERTO)
	else:
		# Entra en estado HERIDO para mostrar flash,
		# pero no interrumpimos la animación de ataque en curso.
		cambiar_estado(Estado.HERIDO)


func hacer_daño() -> int:
	return daño_de_ataque


func _flash_red() -> void:
	# Activa un efecto visual de parpadeo en rojo
	sprite_2d.modulate = Color(1, 0, 0, 1)
	flash_timer = flash_duration
