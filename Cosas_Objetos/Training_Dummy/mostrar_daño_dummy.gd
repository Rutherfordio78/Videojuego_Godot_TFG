extends Label

func _ready():
	modulate.a = 1  # Asegura que el label sea completamente visible

func play_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -50), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", scale * 1.5, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()  # Borrar el nodo después de completar la animación
