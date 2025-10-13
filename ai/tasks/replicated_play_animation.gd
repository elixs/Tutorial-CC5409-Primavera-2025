@tool
extends BTPlayAnimation


func _generate_name() -> String:
	return "ReplicatedPlayAnimation \"%s\"" % animation_name

func _enter() -> void:
	agent.play_animation.rpc(animation_name)
