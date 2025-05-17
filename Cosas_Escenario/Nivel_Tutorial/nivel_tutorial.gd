extends Node2D

@onready var marca_inicio_player: Marker2D = $Player/Marker_Player
@onready var label_3: Label = $Portales/Label3

var jugador_en_area: bool = false

func _ready() -> void:
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
