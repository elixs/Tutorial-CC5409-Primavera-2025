class_name Hitbox
extends Area2D

@warning_ignore("unused_signal")
signal damage_dealt

@export var damage: int = 10

func should_ignore(_hurtbox: Hurtbox) -> bool:
	return false
