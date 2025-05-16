extends Node2D

@onready var marca_inicio_player : Marker2D = $Player/Marker_Player
@onready var marca_portal: Marker2D = $Portal/Marker_Portal

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
	var escena_portal : PackedScene = null
	if Global.veces_cargadas_cementerio == 2:
		escena_portal = preload("res://Cosas_Objetos/Portales/Portal_Zona_Segura/portal_zona_segura.tscn")
	else:
		escena_portal = preload("res://Cosas_Objetos/Portales/Portal_Cementerio/portal_cementerio.tscn")
		
	var portal_instance = escena_portal.instantiate()
	portal_instance.global_position = marca_portal.global_position
	add_child(portal_instance)
