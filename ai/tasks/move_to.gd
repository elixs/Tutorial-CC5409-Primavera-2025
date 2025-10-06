@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var update_time := 1.0

var _nav_agent: NavigationAgent2D
var _timer: Timer

func _generate_name() -> String:
	return "MoveTo -> %s" % LimboUtility.decorate_var(target_var)


func _setup() -> void:
	var nav_agents = agent.find_children("*", "NavigationAgent2D")
	if not nav_agents.is_empty():
		_nav_agent = nav_agents[0]


func _enter() -> void:
	var target: Node2D = blackboard.get_var(target_var)
	if not is_instance_valid(target):
		return
	agent.move_to(target.global_position)
	_timer = Timer.new()
	agent.add_child(_timer)
	_timer.timeout.connect(_update_target_position)
	_timer.start(update_time)


func _tick(_delta: float) -> Status:
	if not is_instance_valid(_nav_agent):
		return FAILURE
	
	if _nav_agent.is_navigation_finished():
		return SUCCESS
	
	return RUNNING


func _exit() -> void:
	agent.stop()
	if _timer:
		_timer.queue_free()


func _update_target_position() -> void:
	var target: Node2D = blackboard.get_var(target_var)
	if not is_instance_valid(_nav_agent) or not is_instance_valid(target):
		return
	_nav_agent.target_position = target.global_position
