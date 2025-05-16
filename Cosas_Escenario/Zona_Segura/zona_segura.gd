extends Node2D

@onready var marca_inicio_player : Marker2D = $Para_El_Player/Marker_Player# Asegurarse de crear el marker en la escena en la que se uso este script
@onready var marca_portal: Marker2D = $Para_El_Portal/Marker_Portal
@onready var marca_portal2: Marker2D = $Para_El_Portal/Marker_Portal_2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cargar_portal()
	cargar_personaje()
	

func cargar_personaje():
	var escena_personaje : PackedScene = null
	# Añadir los player que haya
	if Global.personaje_seleccionado == "Guerrero":
		escena_personaje = preload("res://Cosas_Personajes/Guerrero/player_guerrero.tscn")
	elif Global.personaje_seleccionado == "Samurai":
		escena_personaje = preload("res://Cosas_Personajes/Samurai/player_samurai.tscn")
	elif Global.personaje_seleccionado == "Caperucita":
		escena_personaje = preload("res://Cosas_Personajes/Caperucita_Roja/caperucita_roja.tscn")
	elif Global.personaje_seleccionado == "Guerrera":
		escena_personaje = preload("res://Cosas_Personajes/Guerrera/player_guerrera.tscn") 
	else:
		print("Personaje no reconocido")
		return
	
	var personaje_instance = escena_personaje.instantiate()
	personaje_instance.global_position = marca_inicio_player.global_position
	add_child(personaje_instance)

func cargar_portal():
	var escena_portal: PackedScene = null
	var escena_portal2: PackedScene = null
	
	# 1. Si no se han jugado 3 mapas de pantano, se carga el portal del pantano
	if Global.veces_cargadas_pantano < 3:
		escena_portal = preload("res://Cosas_Objetos/Portales/portal_pantano/portal_pantano.tscn")
	
	# 2. Si ya se han jugado 3 mapas de pantano y aún no se han completado 2 mapas ni del cementerio ni de las cuevas,
	# se cargan ambos portales para que el jugador elija
	elif Global.veces_cargadas_cementerio < 2 and Global.veces_cargadas_cuevas < 2:
		escena_portal = preload("res://Cosas_Objetos/Portales/Portal_Cementerio/portal_cementerio.tscn")
		escena_portal2 = preload("res://Cosas_Objetos/Portales/Portal_Cuevas/portal_cuevas.tscn")
	
	# 3. Si se han completado 2 mapas ya sea del cementerio o de las cuevas, se carga el portal del castillo
	elif Global.veces_cargadas_cementerio >= 2 or Global.veces_cargadas_cuevas >= 2:
		escena_portal = null
	
	# 4. Si se han jugado 2 mapas del castillo, se carga el portal del boss
	elif Global.veces_cargadas_castillo >= 2:
		escena_portal = null
	
	# Instanciamos y posicionamos el portal (o portales)
	if escena_portal:
		var portal_instance = escena_portal.instantiate()
		portal_instance.global_position = marca_portal.global_position
		add_child(portal_instance)
	
	if escena_portal2:
		var portal_instance2 = escena_portal2.instantiate()
		portal_instance2.global_position = marca_portal2.global_position
		add_child(portal_instance2)
