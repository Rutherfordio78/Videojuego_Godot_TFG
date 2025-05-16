extends Control

@onready var musica: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	musica.play()

func _on_re_intentar_pressed() -> void:
	# Reiniciar variables del jugador
	EstadisticasPlayer.Vida_Maxima_Player = 100
	EstadisticasPlayer.vida_actual_Player = 100
	EstadisticasPlayer.FUERZA_SALTO = 300
	EstadisticasPlayer.velocidad = 200.0
	EstadisticasPlayer.base_damage = 10
	EstadisticasPlayer.Buffo_De_Daño_Player = 1.0
	EstadisticasPlayer.Probabilidad_Critico = 0.05 
	EstadisticasPlayer.Daño_Critico = 1.5
	EstadisticasPlayer.monedas = 0
	EstadisticasPlayer.llaves = 0
	EstadisticasPlayer.municion_maxima = 15
	EstadisticasPlayer.municion = 15
	
	# Reiniciar variables de la tienda
	Global.precio_vida = 80
	Global.precio_daño = 80
	Global.precio_cura = 30
	Global.precio_Prb_Crit = 100
	Global.precio_Crit_Dmg = 100
	Global.precio_Ammo_Max = 80
	Global.precio_Ammo = 10
	
	# Reiniciar variables de posesion de la musica
	Global.posesion_Canciones = [true, true, true, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false]

	# Reiniciar contadores de los niveles
	Global.veces_cargadas_pantano = 0
	Global.veces_cargadas_cuevas = 0
	Global.veces_cargadas_castillo = 0
	Global.veces_cargadas_cementerio = 0
	
	# Reiniciar variables del boss
	Global.BOSS_VIVO = true
	
	get_tree().change_scene_to_file("res://Cosas_Escenario/Zona_Segura/zona_segura.tscn") # Cambiar esto al nivel base


func _on_rendirse_pressed() -> void:
	# Reiniciar variables del jugador
	EstadisticasPlayer.Vida_Maxima_Player = 100
	EstadisticasPlayer.vida_actual_Player = 100
	EstadisticasPlayer.FUERZA_SALTO = 300
	EstadisticasPlayer.velocidad = 200.0
	EstadisticasPlayer.base_damage = 10
	EstadisticasPlayer.Buffo_De_Daño_Player = 1.0
	EstadisticasPlayer.Probabilidad_Critico = 0.05 
	EstadisticasPlayer.Daño_Critico = 1.5
	EstadisticasPlayer.monedas = 0
	EstadisticasPlayer.llaves = 0
	EstadisticasPlayer.municion_maxima = 15
	EstadisticasPlayer.municion = 15
	
	# Reiniciar variables de la tienda
	Global.precio_vida = 80
	Global.precio_daño = 80
	Global.precio_cura = 30
	Global.precio_Prb_Crit = 100
	Global.precio_Crit_Dmg = 100
	Global.precio_Ammo_Max = 80
	Global.precio_Ammo = 10
	
	# Reiniciar variables de posesion de la musica
	Global.posesion_Canciones = [true, true, true, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false]

	# Reiniciar contadores de los niveles
	Global.veces_cargadas_pantano = 0
	Global.veces_cargadas_cuevas = 0
	Global.veces_cargadas_castillo = 0
	Global.veces_cargadas_cementerio = 0
	
	get_tree().change_scene_to_file("res://Cosas_Menus/Main_Menu/Main_Menu.tscn")
