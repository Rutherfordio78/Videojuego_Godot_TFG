extends Control

@onready var texto_label: Label = $Panel2/Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cantidad_llaves = EstadisticasPlayer.llaves
	texto_label.text = str(cantidad_llaves)
