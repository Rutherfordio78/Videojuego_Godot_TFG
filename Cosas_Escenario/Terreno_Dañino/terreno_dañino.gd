extends Area2D

@onready var terreno_dañino = $"."

func _ready() -> void:
	terreno_dañino.connect("body_entered", Callable(self, "_on_area_entered"))
	terreno_dañino.connect("body_exited", Callable(self, "_on_area_exited"))

func _on_area_entered(body):
	if body.is_in_group("player"):
		print("Player callendo")
		body.position = body.ultimo_suelo
		EstadisticasPlayer.vida_actual_Player -= 10
		terreno_dañino.disconnect("body_entered", Callable(self, "_on_area_entered"))
		
func _on_area_exited(body):
	terreno_dañino.connect("body_entered", Callable(self, "_on_area_entered"))
