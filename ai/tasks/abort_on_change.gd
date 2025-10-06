@tool
extends BTDecorator

@export var variable: StringName = &""

var _last_variable = null

func _generate_name() -> String:
	return "AbortOnChange -> %s" % LimboUtility.decorate_var(variable)


func _enter() -> void:
	_last_variable = blackboard.get_var(variable)
	

func _tick(delta: float) -> Status:
	var current_variable = blackboard.get_var(variable)
	if current_variable != _last_variable:
		abort()
	_last_variable = current_variable
	return get_child(0).execute(delta)
