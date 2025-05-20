extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	Global.tutorial = 1
	get_tree().change_scene_to_file("res://Cosas_Menus/Menu_Selector_Personajes/Selector_de_Personaje.tscn")


func _on_options_pressed() -> void:
	Global.tutorial = 2
	get_tree().change_scene_to_file("res://Cosas_Menus/Menu_Selector_Personajes/Selector_de_Personaje.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
