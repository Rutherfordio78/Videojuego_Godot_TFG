extends CharacterBody2D

# Velocidad de la bala en píxeles por segundo
var speed: float = 500.0
# Dirección en la que se moverá la bala (por defecto hacia la derecha)
var direction: Vector2 = Vector2.RIGHT
# Tiempo de vida de la bala (segundos)
var lifetime: float = 2.0

var daño = 10

var area_detectada

@onready var sprite = $AnimatedSprite2D2

func _ready() -> void:
	# Se asume que la bala apunta a la dirección de su rotación
	direction = Vector2.RIGHT.rotated(rotation)
	# Conectar la señal del Area2D Detector

func _physics_process(delta: float) -> void:
	# Calcula el movimiento de la bala para este frame
	var motion = direction * speed * delta
	# Intenta mover la bala y comprueba si ocurre una colisión con el entorno
	var collision = move_and_collide(motion)
	if collision:
		# Si colisiona con el entorno, reproducir animación y destruir la bala
		sprite.play("Roto")
		queue_free()
		return

	# Disminuye el tiempo de vida de la bala
	lifetime -= delta
	if lifetime <= 0:
		sprite.play("Roto")
		queue_free()

func hacer_daño(): 
	return daño

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	sprite.play("Roto")
	queue_free()
