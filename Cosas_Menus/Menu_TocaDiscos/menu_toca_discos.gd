extends Control

# Suponiendo que tienes un nodo "Tocadiscos" en la escena que indica la posición de origen del audio
@onready var tocadiscos = $"../.."

@onready var musicas: Array[AudioStreamPlayer2D] = [
	$Canciones/Descanso,
	$Canciones/Comienzo,
	$Canciones/Mediaval,
	$Canciones/Muerte,
	$Canciones/Swamp,
	$Canciones/Castillo,
	$Canciones/Epic,
	$Canciones/Sorpresa,
	$Canciones/Inospito,
	$Canciones/Vacio,
	
	$Canciones/Sagra,
	$Canciones/Misterio,
	$Canciones/Crimen,
	$Canciones/Sinestro,
	$Canciones/Pixel_Adventure,
	$Canciones/Hard_Medieval,
	$Canciones/Festival,
	$Canciones/Progreso,
	$Canciones/EuMalke
]

@onready var Visualizar_Botones_Comprar: Array[Button] = [
	$ScrollContainer/VBoxContainer/Caja_Compra_4/Comprar_4,
	$ScrollContainer/VBoxContainer/Caja_Compra_5/Comprar_5,
	$ScrollContainer/VBoxContainer/Caja_Compra_6/Comprar_6,
	$ScrollContainer/VBoxContainer/Caja_Compra_7/Comprar_7,
	$ScrollContainer/VBoxContainer/Caja_Compra_8/Comprar_8,
	$ScrollContainer/VBoxContainer/Caja_Compra_9/Comprar_9,
	$ScrollContainer/VBoxContainer/Caja_Compra_10/Comprar_10,
	$ScrollContainer/VBoxContainer/Caja_Compra_11/Comprar_11,
	$ScrollContainer/VBoxContainer/Caja_Compra_12/Comprar_12,
	$ScrollContainer/VBoxContainer/Caja_Compra_13/Comprar_13,
	$ScrollContainer/VBoxContainer/Caja_Compra_14/Comprar_14,
	$ScrollContainer/VBoxContainer/Caja_Compra_15/Comprar_15,
	$ScrollContainer/VBoxContainer/Caja_Compra_16/Comprar_16,
	$ScrollContainer/VBoxContainer/Caja_Compra_17/Comprar_17,
	$ScrollContainer/VBoxContainer/Caja_Compra_18/Comprar_18,
	$ScrollContainer/VBoxContainer/Caja_Compra_19/Comprar_19
	
]

@onready var Visualizar_Label_Precios: Array[Label] = [
	$ScrollContainer/VBoxContainer/Caja_Compra_4/Precio_4,
	$ScrollContainer/VBoxContainer/Caja_Compra_5/Precio_5,
	$ScrollContainer/VBoxContainer/Caja_Compra_6/Precio_6,
	$ScrollContainer/VBoxContainer/Caja_Compra_7/Precio_7,
	$ScrollContainer/VBoxContainer/Caja_Compra_8/Precio_8,
	$ScrollContainer/VBoxContainer/Caja_Compra_9/Precio_9,
	$ScrollContainer/VBoxContainer/Caja_Compra_10/Precio_10,
	$ScrollContainer/VBoxContainer/Caja_Compra_11/Precio_11,
	$ScrollContainer/VBoxContainer/Caja_Compra_12/Precio_12,
	$ScrollContainer/VBoxContainer/Caja_Compra_13/Precio_13,
	$ScrollContainer/VBoxContainer/Caja_Compra_14/Precio_14,
	$ScrollContainer/VBoxContainer/Caja_Compra_15/Precio_15,
	$ScrollContainer/VBoxContainer/Caja_Compra_16/Precio_16,
	$ScrollContainer/VBoxContainer/Caja_Compra_17/Precio_17,
	$ScrollContainer/VBoxContainer/Caja_Compra_18/Precio_18,
	$ScrollContainer/VBoxContainer/Caja_Compra_19/Precio_19
]

@onready var Visualizar_Botones_Play: Array[Button] = [
	$ScrollContainer/VBoxContainer/Caja_Compra_4/Reproducir_4,
	$ScrollContainer/VBoxContainer/Caja_Compra_5/Reproducir_5,
	$ScrollContainer/VBoxContainer/Caja_Compra_6/Reproducir_6,
	$ScrollContainer/VBoxContainer/Caja_Compra_7/Reproducir_7,
	$ScrollContainer/VBoxContainer/Caja_Compra_8/Reproducir_8,
	$ScrollContainer/VBoxContainer/Caja_Compra_9/Reproducir_9,
	$ScrollContainer/VBoxContainer/Caja_Compra_10/Reproducir_10,
	$ScrollContainer/VBoxContainer/Caja_Compra_11/Reproducir_11,
	$ScrollContainer/VBoxContainer/Caja_Compra_12/Reproducir_12,
	$ScrollContainer/VBoxContainer/Caja_Compra_13/Reproducir_13,
	$ScrollContainer/VBoxContainer/Caja_Compra_14/Reproducir_14,
	$ScrollContainer/VBoxContainer/Caja_Compra_15/Reproducir_15,
	$ScrollContainer/VBoxContainer/Caja_Compra_16/Reproducir_16,
	$ScrollContainer/VBoxContainer/Caja_Compra_17/Reproducir_17,
	$ScrollContainer/VBoxContainer/Caja_Compra_18/Reproducir_18,
	$ScrollContainer/VBoxContainer/Caja_Compra_19/Reproducir_19
]

func _ready() -> void:
	play_music(0) 
	update_shop_ui()

func play_music(index: int) -> void:
	# Obtén la posición del tocadiscos para usarla como origen del audio
	var tocadiscos_pos: Vector2 = tocadiscos.global_position
	
	# Actualiza la posición de cada AudioStreamPlayer2D
	for musica in musicas:
		musica.global_position = tocadiscos_pos
		musica.stop()
		
	# Reproduce la pista seleccionada
	musicas[index].global_position = tocadiscos_pos
	musicas[index].play()

func update_shop_ui() -> void:
	# Actualiza la visibilidad de los botones en función de la posesión
	# Los elementos en la tienda corresponden a las canciones 4 a 10 (índices 3 a 9)
	for i in range(Visualizar_Botones_Comprar.size()):
		var song_index = i + 3
		# Actualiza el label con el precio de la canción
		Visualizar_Label_Precios[i].text = str(Global.precios_Canciones[song_index])
		if Global.posesion_Canciones[song_index]:
			Visualizar_Botones_Play[i].visible = true
			Visualizar_Botones_Comprar[i].visible = false
		else:
			Visualizar_Botones_Play[i].visible = false
			Visualizar_Botones_Comprar[i].visible = true

func comprar_cancion(song_index: int) -> void:
	# Verifica si la canción ya está en posesión
	if Global.posesion_Canciones[song_index]:
		return
	
	var precio = Global.precios_Canciones[song_index]
	# Verifica si el jugador tiene suficientes monedas
	if EstadisticasPlayer.monedas >= precio:
		EstadisticasPlayer.monedas -= precio
		Global.posesion_Canciones[song_index] = true
		# Actualiza la interfaz: ocultar botón de compra y mostrar botón de play
		var ui_index = song_index - 3
		Visualizar_Botones_Comprar[ui_index].visible = false
		Visualizar_Label_Precios[ui_index].visible = false
		Visualizar_Botones_Play[ui_index].visible = true
		print("¡Canción comprada!")
	else:
		print("No tienes suficientes monedas para comprar esta canción")

# Conexiones de señales para botones de reproducir
func _on_reproducir_1_pressed() -> void:
	play_music(0)

func _on_reproducir_2_pressed() -> void:
	play_music(1)

func _on_reproducir_3_pressed() -> void:
	play_music(2)

func _on_reproducir_4_pressed() -> void:
	play_music(3)

func _on_reproducir_5_pressed() -> void:
	play_music(4)

func _on_reproducir_6_pressed() -> void:
	play_music(5)

func _on_reproducir_7_pressed() -> void:
	play_music(6)

func _on_reproducir_8_pressed() -> void:
	play_music(7)

func _on_reproducir_9_pressed() -> void:
	play_music(8)

func _on_reproducir_10_pressed() -> void:
	play_music(9)

func _on_reproducir_11_pressed() -> void:
	play_music(10)

func _on_reproducir_12_pressed() -> void:
	play_music(11)

func _on_reproducir_13_pressed() -> void:
	play_music(12)

func _on_reproducir_14_pressed() -> void:
	play_music(13)

func _on_reproducir_15_pressed() -> void:
	play_music(14)
	
func _on_reproducir_16_pressed() -> void:
	play_music(15)
	
func _on_reproducir_17_pressed() -> void:
	play_music(16)
	
func _on_reproducir_18_pressed() -> void:
	play_music(17)
	
func _on_reproducir_19_pressed() -> void:
	play_music(18)
	

# Conexiones de señales para botones de comprar
func _on_comprar_4_pressed() -> void:
	comprar_cancion(3)

func _on_comprar_5_pressed() -> void:
	comprar_cancion(4)

func _on_comprar_6_pressed() -> void:
	comprar_cancion(5)

func _on_comprar_7_pressed() -> void:
	comprar_cancion(6)

func _on_comprar_8_pressed() -> void:
	comprar_cancion(7)

func _on_comprar_9_pressed() -> void:
	comprar_cancion(8)

func _on_comprar_10_pressed() -> void:
	comprar_cancion(9)

func _on_comprar_11_pressed() -> void:
	comprar_cancion(10)

func _on_comprar_12_pressed() -> void:
	comprar_cancion(11)

func _on_comprar_13_pressed() -> void:
	comprar_cancion(12)

func _on_comprar_14_pressed() -> void:
	comprar_cancion(13)

func _on_comprar_15_pressed() -> void:
	comprar_cancion(14)

func _on_comprar_16_pressed() -> void:
	comprar_cancion(15)

func _on_comprar_17_pressed() -> void:
	comprar_cancion(16)

func _on_comprar_18_pressed() -> void:
	comprar_cancion(17)

func _on_comprar_19_pressed() -> void:
	comprar_cancion(18)
