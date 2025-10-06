class_name BossBullet
extends Node2D


@export var max_speed = 100
@export var bullet: PackedScene

func _ready() -> void:
	#if is_multiplayer_authority():
	await get_tree().create_timer(2).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += max_speed * transform.x * delta
