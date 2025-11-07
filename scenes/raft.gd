class_name Raft
extends Node2D

@export var path: Path2D
@export var passengers: Array[Node2D]
@export var time: float = 10

var initial_position: Vector2
var started = false
var current_time = 0
var dict: Dictionary[Node2D, Vector2] = {}


@onready var top_shape: CollisionShape2D = %TopShape
@onready var bottom_shape: CollisionShape2D = %BottomShape
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	if is_multiplayer_authority():
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exited)
	await get_tree().create_timer(5).timeout
	start()


func _physics_process(delta: float) -> void:
	if started and is_multiplayer_authority():
		current_time += delta
		if current_time >= time:
			var curve_length = path.curve.get_baked_length()
			var query_pos = path.curve.sample_baked(curve_length)
			global_position = initial_position + query_pos
			stop()
		else:
			var curve_length = path.curve.get_baked_length()
			var query = current_time / time * curve_length
			var query_pos = path.curve.sample_baked(query)
			global_position = initial_position + query_pos


func start() -> void:
	started = true
	bottom_shape.set_deferred("disabled", false)
	start_deferred.call_deferred()


func stop() -> void:
	started = false
	top_shape.set_deferred("disabled", true)


func start_deferred() -> void:
	var query_pos = path.curve.sample_baked(0)
	initial_position = global_position - query_pos
	for passenger in passengers:
		var pos = passenger.global_position
		dict[passenger] = pos
		passenger.get_parent().remove_child(passenger)
		add_child(passenger)
		passenger.global_position = pos


func _on_body_entered(body: Node2D) -> void:
	if started:
		return
	var player = body as Player
	if player:
		add_passenger.rpc(player.get_path())


func _on_body_exited(body: Node2D) -> void:
	if started:
		return
	var player = body as Player
	if player:
		remove_passenger.rpc(player.get_path())

@rpc("reliable", "call_local")
func add_passenger(node_path: NodePath) -> void:
	var node = get_node(node_path)
	Debug.log(node)
	passengers.push_back(node)

@rpc("reliable", "call_local")
func remove_passenger(node_path: NodePath) -> void:
	var node = get_node(node_path)
	Debug.log(node)
	passengers.erase(node)
