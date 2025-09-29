class_name Enemy
extends Node2D


func take_damage(_damage):
	if not is_multiplayer_authority():
		return
	
	Debug.log("Auch enemy")
