class_name EnemyBT
extends CharacterBody2D

signal died()

@export var max_speed = 100

var _movement_enabled = false

@onready var bt_player: BTPlayer = $BTPlayer
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var update_target_timer: Timer = $UpdateTargetTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	bt_player.active = is_multiplayer_authority()
	update_target_timer.timeout.connect(_update_target)
	_update_target()
	health_component.died.connect(_on_died)


func _physics_process(_delta: float) -> void:
	if _movement_enabled:
		if navigation_agent_2d.is_navigation_finished():
			return
		
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()
		var target_velocity = current_agent_position.direction_to(next_path_position) * max_speed
		navigation_agent_2d.velocity = target_velocity


func move_to(target: Vector2) -> void:
	navigation_agent_2d.target_position = target
	navigation_agent_2d.velocity_computed.connect(_on_velocty_computed)
	_movement_enabled = true


func stop() -> void:
	_movement_enabled = false
	if navigation_agent_2d.velocity_computed.is_connected(_on_velocty_computed):
		navigation_agent_2d.velocity_computed.disconnect(_on_velocty_computed)


func test() -> void:
	Debug.log("test")


func _on_velocty_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _update_target() -> void:
	var closest_player = get_closest_player()
	bt_player.blackboard.set_var(&"target", closest_player)


func get_closest_player() -> Player:
	var closest_player: Player = null
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


func _on_died():
	Debug.log("died")
	died.emit()
	queue_free()


@rpc("any_peer", "call_local", "reliable")
func play_animation(animation: String):
	animation_player.play(animation)
