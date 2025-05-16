extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin_area: Area2D = $Area2D
@onready var sonido_moneda: AudioStreamPlayer2D = $AudioStreamPlayer2D

var picked_up: bool = false
var GRAVEDAD = Global.GRAVEDAD  # Traemos la gravedad desde el global

func _ready() -> void:
	coin_area.body_entered.connect(_on_coin_area_body_entered)
	sprite.play("Giro")

func _process(delta: float) -> void:
	if !picked_up:
		apply_central_force(Vector2(0, GRAVEDAD))  # Aplicamos la fuerza de la gravedad

func _on_coin_area_body_entered(body: Node) -> void:
	# Si ya fue recogida, no hacemos nada.
	if picked_up:
		return
	
	if body.is_in_group("player"):
		picked_up = true  # Marcamos la moneda como recogida.
		EstadisticasPlayer.monedas += 20
		sonido_moneda.play()
		
		# Oculta la moneda y deshabilita su colisión
		visible = false
		coin_area.monitoring = false
		
		# Espera el tiempo que dura el sonido antes de liberar el nodo
		var duracion = sonido_moneda.stream.get_length()
		await get_tree().create_timer(duracion/5).timeout
		
		queue_free()
