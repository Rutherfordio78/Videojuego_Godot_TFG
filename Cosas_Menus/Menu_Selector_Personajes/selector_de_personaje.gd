extends CanvasLayer


@onready var Label_Personaje_Seleccionado = $Label
@onready var Imagen_Personaje_Seleccionado = $AnimatedSprite2D

var personajes = ["Guerrero", "Guerrera", "Samurai", "Caperucita"]
var indice_actual = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Imagen_Personaje_Seleccionado.play("Guerrero")
	Label_Personaje_Seleccionado.text = "Guerrero"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_seleccionar_pressed() -> void:
	Global.personaje_seleccionado = personajes[indice_actual]
	get_tree().change_scene_to_file("res://Cosas_Escenario/Zona_Segura/zona_segura.tscn") # cambiar a la escena que toque


func _on_boton_derecha_pressed() -> void:
	indice_actual += 1
	if indice_actual >= personajes.size():
		indice_actual = 0
	Imagen_Personaje_Seleccionado.play(personajes[indice_actual])
	Label_Personaje_Seleccionado.text = personajes[indice_actual]


func _on_boton_izquierda_pressed() -> void:
	indice_actual -= 1
	if indice_actual < 0:
		indice_actual = personajes.size() - 1
	Imagen_Personaje_Seleccionado.play(personajes[indice_actual])
	Label_Personaje_Seleccionado.text = personajes[indice_actual]


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://Cosas_Menus/Main_Menu/Main_Menu.tscn")
