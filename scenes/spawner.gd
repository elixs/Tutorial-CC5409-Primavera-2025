extends MultiplayerSpawner

@export var scene: PackedScene
@export var spawn_maker: Marker2D
@export var enabled: bool = true

@onready var timer: Timer = $Timer

func _ready() -> void:
	if not enabled:
		return
	if scene:
		add_spawnable_scene(scene.resource_path)
	if is_multiplayer_authority():
		timer.timeout.connect(spawn_scene)


func spawn_scene():
	if not scene or not spawn_maker:
		return
	var inst = scene.instantiate()
	inst.global_position = spawn_maker.global_position
	add_child(inst, true)
