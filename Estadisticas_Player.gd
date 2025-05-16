extends Node

# Variable de posicion del jugador
var posicion_Player 

# Variables de estadisticas del personaje
var Vida_Maxima_Player: int = 100
var vida_actual_Player = 100
var FUERZA_SALTO = 300
var velocidad: float = 200.0


# Variables Daño
var daño_de_ataque
var daño_de_ataque_fuerte

var base_damage: int = 10
var Buffo_De_Daño_Player: float = 1.0

const MULTIPLICADOR_ATAQUE_NORMAL: float = 1.0
const MULTIPLICADOR_ATAQUE_FUERTE: float = 2.0

var Probabilidad_Critico: float = 0.05 
var Daño_Critico: float = 1.5

# Recolectables
var monedas = 0
var llaves = 0
var municion_maxima = 15
var municion = 15
