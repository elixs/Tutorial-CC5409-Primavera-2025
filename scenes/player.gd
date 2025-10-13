class_name Player
extends CharacterBody2D

@export var max_speed: int = 100
@export var acceleration: int = 400
@export var bullet_scene: PackedScene

var _respawn_position: Vector2


@onready var label: Label = $Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/movement/playback"]
@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var camera_2d: Camera2D = $Camera2D
@onready var pickable_area_2d: Area2D = $PickableArea2D
@onready var pickable_marker_2d: Marker2D = $PickableMarker2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hud: HUD = $HUD
@onready var health_bar: ProgressBar = %HealthBar
@onready var melee_cooldown: Timer = $MeleeCooldown
@onready var vote_sprite: Sprite2D = $VoteSprite
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_collision_shape: CollisionShape2D = $Hurtbox/HurtboxCollisionShape


var picked_node = null
var pickable: Node2D


func _ready() -> void:
	
	if bullet_scene:
		bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)
	
	hud.setup(health_component)
	health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	health_component.health_changed.connect(func(value): health_bar.value = value)
	health_component.died.connect(_on_died)
	Game.vote_updated.connect(_on_vote_updated)
	vote_sprite.hide()


func _physics_process(delta: float) -> void:

	var move_input = input_synchronizer.move_input
	velocity = velocity.move_toward(move_input * max_speed, acceleration * delta)
	move_and_slide()
	
	if is_multiplayer_authority() and not is_dead():
		if Input.is_action_just_pressed("range") and not animation_tree["parameters/range/active"]:
			fire_server.rpc_id(1, get_global_mouse_position())
		if Input.is_action_just_pressed("melee") and melee_cooldown.is_stopped():
			melee()
		weapon_pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle()
		if Input.is_action_just_pressed("pick"):
			if picked_node:
				drop.rpc()
			else:
				if pickable:
					pick.rpc(pickable.get_path())
		if Input.is_action_just_pressed("test"):
			health_component.health -= 10
					
	if move_input or velocity.length_squared() > 100:
		playback.travel("run")
	else:
		playback.travel("idle")
	
	#if is_multiplayer_authority():
		#if Input.is_action_just_pressed("click"):
			#dot_spawn_requested.emit(get_global_mouse_position())
		

func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
	input_synchronizer.set_multiplayer_authority(player_data.id, false)
	camera_2d.enabled = is_multiplayer_authority()
	hud.visible = is_multiplayer_authority()
	if is_multiplayer_authority():
		pickable_area_2d.body_entered.connect(_on_pickable_body_entered)
		pickable_area_2d.body_exited.connect(_on_pickable_body_exited)
	health_bar.visible = not is_multiplayer_authority()
	health_component.set_multiplayer_authority(player_data.id)

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

func _on_pickable_body_entered(body: Node2D):
	if picked_node:
		return
	if body.is_in_group("Pickable"):
		pickable = body


func _on_pickable_body_exited(body: Node2D):
	if pickable == body:
		pickable = null

@rpc("authority", "call_local", "reliable")
func pick(node_path):
	var node = get_tree().root.get_node(node_path)
	node.get_parent().remove_child(node)
	pickable_marker_2d.add_child(node)
	node.position = Vector2.ZERO
	picked_node = node


@rpc("authority", "call_local", "reliable")
func drop():
	var node = pickable_marker_2d.get_child(0)
	node.get_parent().remove_child(node)
	node.global_position = pickable_marker_2d.global_position
	get_parent().add_child(node)
	picked_node = null

func melee() -> void:
	melee_cooldown.start()

func heal(value: int) -> void:
	if not multiplayer.is_server():
		return
	health_component.health += value


func _on_vote_updated(id: int, vote: bool) -> void:
	if get_multiplayer_authority() == id:
		vote_sprite.visible = vote


func _on_died() -> void:
	sprite_2d.modulate = Color(1, 1, 1, 0.25)
	collision_shape_2d.set_deferred("disabled", true)
	hurtbox_collision_shape.set_deferred("disabled", true)
	_respawn_position = global_position


func is_dead():
	return health_component.health == 0


@rpc("any_peer", "call_local", "reliable")
func respawn():
	if not is_dead():
		return
	sprite_2d.modulate = Color.WHITE
	collision_shape_2d.set_deferred("disabled", false)
	hurtbox_collision_shape.set_deferred("disabled", false)
	if is_multiplayer_authority():
		global_position = _respawn_position
		health_component.health = health_component.max_health
