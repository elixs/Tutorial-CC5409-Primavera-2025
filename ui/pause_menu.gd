class_name UIPauseMenu
extends CanvasLayer

@onready var pauser: Label = %Pauser

var pause_owner: bool = false

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not pause_owner and not get_tree().paused:
			set_pause.rpc(true)
			pause_owner = true
		elif pause_owner and get_tree().paused:
			set_pause.rpc(false)
			pause_owner = false


@rpc("any_peer", "call_local", "reliable")
func set_pause(value: bool) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	var player_data = Game.get_player(sender_id)
	get_tree().paused = value
	visible = value
	pauser.text = player_data.name
