class_name Boss
extends Node2D


@export var bullet_scene: PackedScene

@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var left_eye: Marker2D = $LeftEye
@onready var right_eye: Marker2D = $RightEye
@onready var bullet_spawn: Marker2D = $BulletSpawn

func _ready() -> void:
	bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)
	
	await get_tree().create_timer(1).timeout
	choose_next_strategy()


func choose_next_strategy():
	await spread(get_closest_player(), 10, 1, 2)
	await get_tree().create_timer(2).timeout
	choose_next_strategy()


func spread(target: Node2D, rate: float, angle: float, time: float) -> void:
	var amount = rate * time
	for i in amount:
		var direction = bullet_spawn.global_position.direction_to(target.global_position)
		var rot = direction.angle() + deg_to_rad(randf_range(-angle, angle))
		var pos = bullet_spawn.global_position
		spawn_bullet(pos, rot)
		await get_tree().create_timer(1/rate).timeout


func spawn_bullet(pos: Vector2, rot: float):
	if not bullet_scene:
		return
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = pos
	bullet_inst.global_rotation = rot
	bullet_spawner.add_child(bullet_inst, true)


func get_closest_player() -> Player:
	var closest_player = null
	var closest_distance = 0
	for player_data in Game.players:
		if not player_data.scene:
			continue
		var player_position = player_data.scene.global_position
		var player_distance = global_position.distance_to(player_position)
		if not closest_player or player_distance < closest_distance:
			closest_player = player_data.scene
			closest_distance = player_distance

	return closest_player
