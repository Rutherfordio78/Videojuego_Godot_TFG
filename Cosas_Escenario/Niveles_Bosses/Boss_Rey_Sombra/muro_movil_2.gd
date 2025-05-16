extends StaticBody2D

var original_position: Vector2  # Posición original del muro.
var offset: float = 110         # Píxeles que se desplazará el muro.
var has_moved: bool = false     # Bandera para asegurarnos de que el muro se mueva solo una vez.

func _ready() -> void:
	original_position = position

func _process(delta: float) -> void:
	if Global.BOSS_VIVO == false:
		_on_boss_dead()

func _on_boss_dead() -> void:
	if not has_moved:
		has_moved = true
		var tween = create_tween()
		tween.tween_property(self, "position", position - Vector2(0, offset), 0.5) \
			.set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT)
