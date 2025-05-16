extends Control

@onready var texto_label: Label = $Panel/Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cantidad_monedas = EstadisticasPlayer.municion
	texto_label.text = str(cantidad_monedas)
