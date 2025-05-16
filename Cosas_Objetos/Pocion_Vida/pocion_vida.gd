extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pocion_area: Area2D = $Area2D
@onready var sonido_pocion: AudioStreamPlayer2D = $AudioStreamPlayer2D

var picked_up: bool = false
var GRAVEDAD = Global.GRAVEDAD  # Traemos la gravedad desde el global

func _ready() -> void:
	pocion_area.body_entered.connect(_on_pocion_area_body_entered)
	sprite.play("Giro")  # Iniciamos la animación de giro

func _physics_process(delta: float) -> void:
	if !picked_up:
		apply_central_force(Vector2(0, GRAVEDAD))  # Aplicamos la fuerza de la gravedad

func _on_pocion_area_body_entered(body: Node) -> void:
	# Si ya fue recogida, no hacemos nada.
	if picked_up:
		return
	
	if body.is_in_group("player"):
		picked_up = true  # Marcamos como recogida.
		
		var porcentaje_curacion = 10  # El porcentaje de curación que deseas aplicar
		var vida_maxima = EstadisticasPlayer.Vida_Maxima_Player  # La vida máxima del jugador
		var curacion = (vida_maxima * porcentaje_curacion) / 100  # Calcula la curación como un porcentaje de la vida máxima
		EstadisticasPlayer.vida_actual_Player = min(EstadisticasPlayer.vida_actual_Player + curacion, vida_maxima)  # Aplica la curación, pero no excede la vida máxima

		sonido_pocion.play()
		
		# Oculta la moneda y deshabilita su colisión
		visible = false
		pocion_area.monitoring = false
		
		# Espera el tiempo que dura el sonido antes de liberar el nodo
		var duracion = sonido_pocion.stream.get_length()
		await get_tree().create_timer(duracion).timeout
		
		queue_free()
