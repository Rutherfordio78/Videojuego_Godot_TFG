extends Control

@onready var menu_pausar_juego: Control = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quitar_pausa_pressed() -> void:
	get_tree().paused = false
	menu_pausar_juego.visible = false


func _on_rendirse_pressed() -> void:
	get_tree().paused = false
	menu_pausar_juego.visible = false
	
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
