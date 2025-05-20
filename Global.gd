extends Node

var personaje_seleccionado: String = "Guerrera"

var GRAVEDAD = 500

var BOSS_VIVO = true

var tutorial = 0

# --------------------
# Variables de la Tienda
# --------------------
var precio_vida: int = 80
var precio_daño: int = 80
var precio_cura: int = 30
var precio_Prb_Crit: int = 100
var precio_Crit_Dmg: int = 100
var precio_Ammo_Max :int = 80
var precio_Ammo: int = 10

# --------------------
# Variables de la Gramola
# --------------------

var precios_Canciones: Array[int] = [0, 0, 0, 100, 200, 300, 250, 1000, 200, 100, 0, 100, 200, 150, 200, 100, 300, 350, 150]

var posesion_Canciones: Array[bool] = [true, true, true, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false]

# --------------------
# Funciones Reutilizables Para cambiar de mapa
# --------------------

var MAPAS_PANTANO = [preload("res://Cosas_Escenario/Niveles_Pantano/Version_1/nivel_pantano_1.tscn"),
					preload("res://Cosas_Escenario/Niveles_Pantano/Version_2/nivel_pantano_2.tscn"),
					preload("res://Cosas_Escenario/Niveles_Pantano/Version_3/nivel_pantano_3.tscn")]

var MAPAS_CUEVAS = [preload("res://Cosas_Escenario/Niveles_Cuevas/Version_1/nivel_cuevas_1.tscn"),
					preload("res://Cosas_Escenario/Niveles_Cuevas/Version_2/nivel_cuevas_2.tscn")]

var MAPAS_CEMENTERIO = [preload("res://Cosas_Escenario/Niveles_Cementerio/Version_1/nivel_cementerio_1.tscn"),
						preload("res://Cosas_Escenario/Niveles_Cementerio/Version_2/nivel_cementerio_2.tscn")]

var MAPAS_CASTILLO = [preload("res://Cosas_Escenario/Niveles_Castillo/Version_1/nivel_castillo_1.tscn")]

var MAPAS_BOSS = [preload("res://Cosas_Escenario/Niveles_Bosses/Boss_Rey_Sombra/nivel_boss_rey_sombra.tscn")]

var MAPA_ZONA_SEGURA = preload("res://Cosas_Escenario/Zona_Segura/zona_segura.tscn")

var mapa_actual 

var mapa_enviado 

var veces_cargadas_pantano: int = 0
var veces_cargadas_cuevas: int = 0
var veces_cargadas_castillo: int = 0
var veces_cargadas_cementerio: int = 0

func cargar_siguiente_mapa(tema: String):
	match tema:
		"ZONA_SEGURA":
			mapa_enviado = MAPA_ZONA_SEGURA
		"PANTANO":
			veces_cargadas_pantano += 1
			mapa_enviado = MAPAS_PANTANO.pick_random()
			while mapa_enviado == mapa_actual:
				mapa_enviado = MAPAS_PANTANO.pick_random()
		"CUEVAS":
			veces_cargadas_cuevas += 1
			mapa_enviado = MAPAS_CUEVAS.pick_random()
			while mapa_enviado == mapa_actual:
				mapa_enviado = MAPAS_CUEVAS.pick_random()
		"CASTILLO":
			veces_cargadas_castillo += 1
			mapa_enviado = MAPAS_CASTILLO.pick_random()
			while mapa_enviado == mapa_actual:
				mapa_enviado = MAPAS_CASTILLO.pick_random()
		"CEMENTERIO":
			veces_cargadas_cementerio += 1
			mapa_enviado = MAPAS_CEMENTERIO.pick_random()
			while mapa_enviado == mapa_actual:
				mapa_enviado = MAPAS_CEMENTERIO.pick_random()
		"BOSS":
			mapa_enviado = MAPAS_BOSS.pick_random()
			while mapa_enviado == mapa_actual:
				mapa_enviado = MAPAS_BOSS.pick_random()
		_:
			print("El tema especificado no existe: ", tema)
			return null
			
	mapa_actual = mapa_enviado
	return mapa_enviado


# --------------------
# Funciones Reutilizables Dropear Items
# --------------------

var ITEMS_DROPEABLES_NORMALES = [preload("res://Cosas_Objetos/Llave/Llave.tscn"), 
						preload("res://Cosas_Objetos/Moneda_Oro/Gold_Coin.tscn"), 
						preload("res://Cosas_Objetos/Moneda_Plata/Silver_Coin.tscn"),
						preload("res://Cosas_Objetos/Pocion_Vida/pocion_vida.tscn")] 

var ITEMS_DROPEABLES_ESPECIALES = [preload("res://Cosas_Objetos/Diamante_Azul/diamante_azul.tscn"),
						preload("res://Cosas_Objetos/Diamante_Rojo/diamante_rojo.tscn")] 


func Dropear_Items_Normales() -> Node:
	# Selecciona un ítem aleatorio de la lista normal.
	var random_index = randi() % ITEMS_DROPEABLES_NORMALES.size()
	var item_scene = ITEMS_DROPEABLES_NORMALES[random_index]
	# Instancia el ítem y lo retorna.
	return item_scene.instantiate()


func Dropear_Items_Especiales() -> Array:
	var dropped_items = []
	# Se generan 2 ítems.
	for i in range(2):
		# Genera un número aleatorio entre 0 y 1.
		var chance = randf()
		var item_scene : PackedScene
		# Con 60% de probabilidad selecciona de la lista especial,
		# y con 40% de la lista normal.
		if chance < 0.6:
			var random_index = randi() % ITEMS_DROPEABLES_ESPECIALES.size()
			item_scene = ITEMS_DROPEABLES_ESPECIALES[random_index]
		else:
			var random_index = randi() % ITEMS_DROPEABLES_NORMALES.size()
			item_scene = ITEMS_DROPEABLES_NORMALES[random_index]
		# Instancia el ítem y lo agrega a la lista.
		dropped_items.append(item_scene.instantiate())
		
	return dropped_items

# --------------------
# Funciones DataBase
# --------------------

var datos 

func guardar_datos():
	var archivo = FileAccess.open("user://datos.json", FileAccess.WRITE)
	if archivo:
		# Serializamos los datos a una cadena JSON.
		var json_string = JSON.stringify(datos)
		archivo.store_string(json_string)
		archivo.close()
	else:
		print("Error al abrir el archivo para escribir.")



func cargar_datos():
	if FileAccess.file_exists("user://datos.json"):
		var archivo = FileAccess.open("user://datos.json", FileAccess.READ)
		if archivo:
			var contenido = archivo.get_as_text()
			archivo.close()
			
			# Creamos una nueva instancia de JSON para parsear la cadena.
			var json = JSON.new()
			var error = json.parse(contenido)
			if error == OK:
				# Obtenemos los datos parseados.
				datos = json.data
			else:
				print("Error al parsear JSON: ", json.get_error_message(), " en ", contenido)
		else:
			print("Error al abrir el archivo para leer.")
	else:
		print("El archivo no existe.")
