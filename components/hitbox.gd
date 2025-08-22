class_name Hitbox
extends Area2D

signal damage_dealt

@export var damage: int = 10

func should_ignore(hurtbox: Hurtbox) -> bool:
	return false
