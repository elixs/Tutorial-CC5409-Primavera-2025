class_name Enemy
extends Node2D


func take_damage(damage):
	if not is_multiplayer_authority():
		return
	
	Debug.log("Auch enemy")
