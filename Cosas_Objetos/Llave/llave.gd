extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var llave_area: Area2D = $Area2D
@onready var sonido_llave: AudioStreamPlayer2D = $AudioStreamPlayer2D

var picked_up: bool = false
var GRAVEDAD = Global.GRAVEDAD  # Traemos la gravedad desde el global

func _ready() -> void:
	llave_area.body_entered.connect(_on_llave_area_body_entered)
	sprite.play("Giro")

func _process(delta: float) -> void:
	if !picked_up:
		apply_central_force(Vector2(0, GRAVEDAD))  # Aplicamos la fuerza de la gravedad
	
func _on_llave_area_body_entered(body: Node) -> void:
	# Si ya fue recogida, no hacemos nada.
	if picked_up:
		return
	
	if body.is_in_group("player"):
		picked_up = true  # Marcamos la moneda como recogida.
		EstadisticasPlayer.llaves += 1
		sonido_llave.play()
		
		# Oculta la moneda y deshabilita su colisión
		visible = false
		llave_area.monitoring = false
		
		# Espera el tiempo que dura el sonido antes de liberar el nodo
		await get_tree().create_timer(0.8).timeout
		
		queue_free()
