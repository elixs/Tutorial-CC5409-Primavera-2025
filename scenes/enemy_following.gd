extends CharacterBody2D


@export var max_speed = 100

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var path_update_timer: Timer = $PathUpdateTimer

func _ready() -> void:
	if is_multiplayer_authority():
		path_update_timer.timeout.connect(update_target)

func _physics_process(_delta: float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent_2d.get_next_path_position()
	velocity = current_agent_position.direction_to(next_path_position) * max_speed
	move_and_slide()


func update_target():
	var closest_target = null
	var closest_distance = 0
	for player_data in Game.players:
		if not player_data.scene:
			continue
		var player_position = player_data.scene.global_position
		var player_distance = global_position.distance_to(player_position)
		if not closest_target or player_distance < closest_distance:
			closest_target = player_position
			closest_distance = player_distance
	if closest_target:
		set_target(closest_target)

func set_target(target_postion: Vector2):
	navigation_agent_2d.target_position = target_postion
	
