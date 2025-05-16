extends Node2D

@onready var marker_boss: Marker2D = $Boss/Marker_Boss
@onready var area_inicio_pelea: Area2D = $Boss/Area_Inicio_Pelea2/Area_Inicio_Pelea
@onready var marker_portal: Marker2D = $Portal/Marker_Portal
@onready var marker_player: Marker2D = $Player/Marker_Player
@onready var audio_stream_player: AudioStreamPlayer = $Musica/AudioStreamPlayer

var boss_scene = preload("res://Cosas_Enemigos/Rey_Sombrio_Boss/rey_sombrio_boss.tscn")

var boss_invocado = false

var fade_speed = 5.0  # Velocidad de disminución del volumen
var min_volume = -80  # Volumen mínimo (silencio total)

@onready var marker_2d: Marker2D = $Premios/Marker2D
@onready var marker_2d_2: Marker2D = $Premios/Marker2D2
@onready var marker_2d_3: Marker2D = $Premios/Marker2D3
@onready var marker_2d_4: Marker2D = $Premios/Marker2D4
@onready var marker_2d_5: Marker2D = $Premios/Marker2D5
@onready var marker_2d_6: Marker2D = $Premios/Marker2D6
@onready var marker_2d_7: Marker2D = $Premios/Marker2D7
@onready var marker_2d_8: Marker2D = $Premios/Marker2D8
@onready var marker_2d_9: Marker2D = $Premios/Marker2D9
@onready var marker_2d_10: Marker2D = $Premios/Marker2D10
@onready var marker_2d_11: Marker2D = $Premios/Marker2D11
@onready var marker_2d_12: Marker2D = $Premios/Marker2D12
@onready var marker_2d_13: Marker2D = $Premios/Marker2D13

var markers_Premios

var premios_existen = false

func _ready() -> void:
	randomize()
	Global.BOSS_VIVO = true
	cargar_portal()
	cargar_personaje()
	
	markers_Premios = [
		marker_2d,
		marker_2d_2,
		marker_2d_3,
		marker_2d_4,
		marker_2d_5,
		marker_2d_6,
		marker_2d_7,
		marker_2d_8,
		marker_2d_9,
		marker_2d_10,
		marker_2d_11,
		marker_2d_12,
		marker_2d_13
	]

func _process(delta: float) -> void:
	if Global.BOSS_VIVO == false:
		audio_stream_player.volume_db = max(audio_stream_player.volume_db - fade_speed * delta, min_volume)
		if audio_stream_player.volume_db <= min_volume:
			audio_stream_player.stop()
		
		if premios_existen == false:
			premios_existen = true
			invocar_premios()


func _on_area_inicio_pelea_body_entered(body: Node2D) -> void:
	if boss_invocado == false:
		var boss = boss_scene.instantiate()
		boss.global_position = marker_boss.global_position
		get_parent().add_child(boss)
		boss.global_position = marker_boss.global_position
		boss_invocado = true
		audio_stream_player.play()


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
	personaje_instance.global_position = marker_player.global_position
	add_child(personaje_instance)
	personaje_instance.global_position = marker_player.global_position


func cargar_portal():
	var escena_portal : PackedScene = null
	escena_portal = preload("res://Cosas_Objetos/Portales/Portal_Zona_Segura/portal_zona_segura.tscn")
	
	var portal_instance = escena_portal.instantiate()
	portal_instance.global_position = marker_portal.global_position
	add_child(portal_instance)
	portal_instance.global_position = marker_portal.global_position
	
	
func invocar_premios():
	var premios_posibles = [
		preload("res://Cosas_Objetos/Diamante_Azul/diamante_azul.tscn"),
		preload("res://Cosas_Objetos/Diamante_Rojo/diamante_rojo.tscn"),
		preload("res://Cosas_Objetos/Moneda_Oro/Gold_Coin.tscn")
	]
	
	var cantidad_de_premios = 30
	
	for i in range(cantidad_de_premios):
		# Seleccionar aleatoriamente una escena de premio
		var indice_premio = randi() % premios_posibles.size()
		var premio_scene = premios_posibles[indice_premio]
		var premio_instance = premio_scene.instantiate()
		
		# Seleccionar aleatoriamente uno de los markers de premios
		var indice_marker = randi() % markers_Premios.size()
		var marker = markers_Premios[indice_marker]
		
		# Posicionar la instancia del premio en la posición del marker
		premio_instance.global_position = marker.global_position
		add_child(premio_instance)
		premio_instance.global_position = marker.global_position
