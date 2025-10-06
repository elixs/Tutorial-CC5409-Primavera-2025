class_name Item
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var data: ItemData:
	set = set_data

func _ready() -> void:
	if not multiplayer.is_server():
		return
	body_entered.connect(_on_body_entered)


func update():
	if not is_node_ready() or not data:
		return
	sprite_2d.texture = data.image

func set_data(value) -> void:
	data = value
	update()


func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		if data:
			data.use(player.get_multiplayer_authority())
		_destroy.rpc()


@rpc("call_local", "reliable")
func _destroy() -> void:
	queue_free()
