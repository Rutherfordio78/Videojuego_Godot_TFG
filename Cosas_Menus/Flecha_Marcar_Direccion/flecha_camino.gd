extends Sprite2D

# Variables para controlar el movimiento
var amplitud: float = 10.0  # Qué tanto sube y baja (en píxeles)
var velocidad: float = 2.0  # Velocidad de la animación

# Posición inicial del sprite
var posicion_inicial: Vector2

func _ready():
	# Guardamos la posición inicial cuando se inicia el nodo
	posicion_inicial = position

func _process(delta):
	# Calculamos el desplazamiento usando una función seno para un movimiento suave
	var desplazamiento = sin(Time.get_ticks_msec() * 0.001 * velocidad) * amplitud
	
	# Actualizamos la posición del sprite (solo en el eje Y)
	position.y = posicion_inicial.y + desplazamiento
