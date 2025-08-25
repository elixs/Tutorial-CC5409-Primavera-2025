class_name Raft
extends Node2D

@export var a: Marker2D
@export var b: Marker2D

var in_on_a = true

func toggle():
	if not a or not b:
		return
	var tween = create_tween()
	var target_position = a.global_position if in_on_a else b.global_position
	tween.tween_property(self, "global_position", target_position, 1)
	in_on_a = not in_on_a
