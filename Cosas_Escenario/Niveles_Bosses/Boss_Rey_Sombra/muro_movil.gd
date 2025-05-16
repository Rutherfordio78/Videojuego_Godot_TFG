extends StaticBody2D

var original_position: Vector2  # Guarda la posición original del muro.
var offset: float = 110  # Píxeles que el muro se desplaza.
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	original_position = position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		audio_stream_player_2d.play()
		# Crea y configura el tween para subir el muro.
		var tween = create_tween()
		tween.tween_property(self, "position", position - Vector2(0, offset), 1) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		audio_stream_player_2d.play()
		# Crea y configura el tween para bajar el muro a su posición original.
		var tween = create_tween()
		tween.tween_property(self, "position", original_position, 1) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_IN)
