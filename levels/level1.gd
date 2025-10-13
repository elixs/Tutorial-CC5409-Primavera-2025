extends Node2D

@export var player_scene: PackedScene
@export var knight_scene: PackedScene

@onready var players: Node2D = %Players
@onready var markers: Node2D = %Markers


func _ready() -> void:
	if not player_scene or not knight_scene:
		return
	
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = null
		if player_data.role == Statics.Role.ROLE_B:
			player_inst = knight_scene.instantiate()
		else:
			player_inst = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.global_position = markers.get_child(i).global_position
		player_inst.setup(player_data)
		player_data.scene = player_inst
	
	if not is_multiplayer_authority():
		return
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy_bt = node as EnemyBT
		if enemy_bt:
			enemy_bt.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	for player_data in Game.players:
		var player = player_data.scene
		player.respawn.rpc()
