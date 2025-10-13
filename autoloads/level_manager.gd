extends Node

@export var levels: Array[PackedScene]
@export var credits: PackedScene

var current_level_index = 0


func next_level():
	current_level_index += 1
	_go_to_level.rpc(current_level_index)


@rpc("call_local", "reliable")
func _go_to_level(index) -> void:
	if levels.size() > index:
		get_tree().change_scene_to_packed(levels[index])
	else:
		get_tree().change_scene_to_packed(credits)
