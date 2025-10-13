@tool
extends BTConsolePrint

func _generate_name() -> String:
	return "DebugLog text: \"%s\"" % text

func _tick(_delta: float) -> Status:
	Debug.log(text)
	return SUCCESS
