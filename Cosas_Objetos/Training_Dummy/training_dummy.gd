extends RigidBody2D

@onready var damage_label_scene: PackedScene = preload("res://Cosas_Objetos/Training_Dummy/mostrar_daño_dummy.tscn")
@onready var posicion_Label = $Marker2D
@onready var sprite = $AnimatedSprite2D
@onready var sonido = $AudioStreamPlayer2D

func recibir_daño(daño_recibido):
	# Instancia un nuevo Label de daño
	var damage_label = damage_label_scene.instantiate()
	add_child(damage_label)

	# Configura la posición y el texto usando la posición del Marker2D
	damage_label.position = posicion_Label.position
	damage_label.text = "+" + str(daño_recibido)
	sprite.play("Golpeado")
	sonido.play()
	# Reproducir animación (definida en el Label)
	damage_label.play_animation()
