class_name HealthComponent
extends Node

signal health_changed(value)

@export var health = 100:
	set(value):
		health = value
		health_changed.emit(health)
@export var max_health  = 100
