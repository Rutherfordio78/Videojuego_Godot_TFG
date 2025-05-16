extends CharacterBody2D

const SPEED = 350.0
var daño = 20
var ultima_posicion_del_player
var direccion_inicial = Vector2.ZERO
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

enum State {
	APARICION,
	IDLE,
	MUERTE
}

var estado_actual = State.APARICION

func _ready() -> void:
	ultima_posicion_del_player = EstadisticasPlayer.posicion_Player

func _physics_process(delta: float) -> void:

	if estado_actual == State.APARICION:
		animated_sprite_2d.play("Aparecer")
		direccion_inicial = (ultima_posicion_del_player - global_position).normalized()
		await get_tree().create_timer(0.5).timeout
		estado_actual = State.IDLE
		
	if estado_actual == State.IDLE:
		velocity = direccion_inicial * SPEED

		# Manejo de la dirección (flip_h)
		if direccion_inicial.x < 0:
			animated_sprite_2d.flip_h = true  # Mirar a la izquierda
		else:
			animated_sprite_2d.flip_h = false  # Mirar a la derecha
		
		animated_sprite_2d.play("Idle")
		move_and_slide()
		

	if estado_actual == State.MUERTE:
		$Area2D/CollisionShape2D.disabled = true
		animated_sprite_2d.play("Morir")
		await get_tree().create_timer(1).timeout
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("chocamos con player")
	estado_actual = State.MUERTE

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	print("chocamos con pared")
	estado_actual = State.MUERTE

func hacer_daño() -> int:
	return daño
