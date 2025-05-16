extends Node2D

# Definimos dos señales:
signal Algo_Golpeado(area) 
signal Golpe_Recibido(area)

@onready var hurt_box = $Hurt_Box      # Referencia al Area2D de la "Hurt_Box"
@onready var hit_box = $Hit_Box        # Referencia al Area2D de la "Hit_Box"

func _ready():
	# Conectamos las señales de 'body_entered' de cada Area2D a funciones locales.
	# Asegúrate de que Hurt_Box y Hit_Box estén configuradas como Area2D en el editor.
	hurt_box.connect("area_entered", Callable(self, "_on_hurt_box_area_entered"))
	hit_box.connect("area_entered", Callable(self, "_on_hit_box_area_entered"))

func _on_hurt_box_area_entered(area):
	# Si la hurt box detecta un 'body' al que podemos dañar, 
	# emitimos la señal correspondiente para que el personaje maneje el "dar daño".
	print("rana Hurt_Box detectó un area:", area)
	emit_signal("Algo_Golpeado", area)

func _on_hit_box_area_entered(area):
	# Si 'body' es el objeto que nos golpea, podemos emitir una señal
	# para que el script del personaje maneje la lógica de recibir daño.
	print("rana Hit_Box detectó un area:", area)
	emit_signal("Golpe_Recibido", area)
