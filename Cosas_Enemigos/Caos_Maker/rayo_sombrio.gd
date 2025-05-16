extends Node2D

# Parámetro para el daño que causa el rayo
var daño_de_ataque = 20

# Referencia al jugador (opcional, se puede buscar en _ready)
@onready var Area_Rayo: Area2D = $Area_Del_Rayo
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	animation_player.play("Rayo")
	Area_Rayo.connect("area_entered", Callable(self, "_on_Algo_Golpeado"))
	
	
func _on_LifeTimer_timeout():
	queue_free()


func hacer_daño():
	return daño_de_ataque
