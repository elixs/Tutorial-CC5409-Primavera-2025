extends Area2D


func _ready() -> void:
	if not is_multiplayer_authority():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		Game.set_player_vote.rpc(player.get_multiplayer_authority(), true)
		check_next_level()


func _on_body_exited(body: Node2D) -> void:
	var player = body as Player
	if player:
		Game.set_player_vote.rpc(player.get_multiplayer_authority(), false)


func check_next_level():
	if Game.has_all_voted():
		LevelManager.next_level()
