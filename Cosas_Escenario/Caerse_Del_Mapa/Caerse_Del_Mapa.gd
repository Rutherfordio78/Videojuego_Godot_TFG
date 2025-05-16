extends Area2D

@onready var Area_Caida = $"."

func _ready() -> void:
	Area_Caida.connect("body_entered", Callable(self, "_on_area_entered"))
	Area_Caida.connect("body_exited", Callable(self, "_on_area_exited"))

func _on_area_entered(body):
	if body.is_in_group("player"):
		print("Player callendo")
		body.position = body.ultimo_suelo
		EstadisticasPlayer.vida_actual_Player -= 10
		Area_Caida.disconnect("body_entered", Callable(self, "_on_area_entered"))
		
func _on_area_exited(body):
	Area_Caida.connect("body_entered", Callable(self, "_on_area_entered"))
