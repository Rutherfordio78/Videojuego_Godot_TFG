extends HBoxContainer

@onready var corazon_vida: TextureProgressBar = $Corazon_Vida
@onready var barra_vida: TextureProgressBar = $Barra_Vida


func _process(delta: float) -> void:
	actualizar_vida(EstadisticasPlayer.vida_actual_Player)
	barra_vida.max_value = EstadisticasPlayer.Vida_Maxima_Player - 10
	

# Función para actualizar la visualización de la vida
func actualizar_vida(vida: int) -> void:
	# Aseguramos que la vida esté entre 0 y vida maxima
	vida = clamp(vida, 0, EstadisticasPlayer.Vida_Maxima_Player)
	
	if vida > 10:
		# Los primeros 90 puntos se muestran en barra_vida y los últimos 10 en corazon_vida
		barra_vida.value = vida - 10
		corazon_vida.value = 10
	else:
		# Si la vida es 10 o menor, la barra principal se queda vacía
		barra_vida.value = 0
		corazon_vida.value = vida
