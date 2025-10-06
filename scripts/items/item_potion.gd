extends ItemData

@export var health: int


func use(player_id: int) -> void:
	if not Game.multiplayer.is_server():
		return
		
	var player: Player = Game.get_player(player_id).scene
	player.heal(health)
