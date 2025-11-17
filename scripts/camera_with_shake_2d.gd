class_name CameraWithShake2D
extends Camera2D


func shake(intensity: float = 6, duration: float = 0.2, steps: int = 12) -> void:
	var step_duration = duration / steps
	var tween = create_tween()
	for i in steps:
		var new_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(self, "offset", new_offset, step_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "offset", Vector2(), step_duration)
