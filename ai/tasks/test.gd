extends BTAction

func _tick(_delta: float) -> Status:
	agent.test()
	return SUCCESS
