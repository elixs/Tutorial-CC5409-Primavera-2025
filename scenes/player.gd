class_name Player
extends CharacterBody2D

signal dot_spawn_requested

@export var max_speed: int = 100
@export var acceleration: int = 400
@export var bullet_scene: PackedScene

@onready var label: Label = $Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/movement/playback"]
@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner

func _ready() -> void:
	if bullet_scene:
		bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)

func _physics_process(delta: float) -> void:

	var move_input = input_synchronizer.move_input
	velocity = velocity.move_toward(move_input * max_speed, acceleration * delta)
	move_and_slide()
	
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("range") and not animation_tree["parameters/range/active"]:
			fire_server.rpc_id(1, get_global_mouse_position())
	
	
	
	if move_input or velocity.length_squared() > 100:
		playback.travel("run")
	else:
		playback.travel("idle")
	
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("click"):
			dot_spawn_requested.emit(get_global_mouse_position())


func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
	input_synchronizer.set_multiplayer_authority(player_data.id, false)


@rpc("any_peer", "call_local", "reliable")
func test():
	Debug.log("test: %s" % [label.text] )

@rpc("authority", "call_remote", "unreliable_ordered")
func send_pos(pos):
	position = pos
	

func take_damage(damage: int):
	Debug.log("Auch %d" % damage)


func fire(pos):
	if not bullet_scene:
		return
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = global_position
	bullet_inst.global_rotation = global_position.direction_to(pos).angle()
	bullet_spawner.add_child(bullet_inst, true)

@rpc("authority", "call_local", "reliable")
func fire_server(pos):
	fire(pos)
	fire_anim.rpc()


@rpc("any_peer", "call_local", "reliable")
func fire_anim():
	animation_tree["parameters/range/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
