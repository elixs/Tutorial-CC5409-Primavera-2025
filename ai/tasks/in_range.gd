@tool
extends BTCondition

@export var target_var: StringName = &"target"

@export var min_distance := 0.0
@export var max_distance := 50.0

func _generate_name() -> String:
	return "InRange [%.2f, %.2f] -> %s" % [min_distance, max_distance
	, LimboUtility.decorate_var(target_var)]

func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return FAILURE
	var distance = agent.global_position.distance_to(target.global_position)
	if distance >= min_distance and distance <= max_distance:
		return SUCCESS
	return FAILURE
