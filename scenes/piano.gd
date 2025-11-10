extends Node2D

@export var keys = 4
@export var width = 200
@export var height = 100
@export var texture: Texture2D
@export var audio_stream: AudioStream

var _audio_player_map: Dictionary[int, AudioStreamPlayer] = {}

#var _audio_map: Dictionary[Player, AudioStreamPlayer] = {}

#var _players_inside: Array[Player] = []

func _ready() -> void:
	for key in keys:
		var area = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		var sprite = Sprite2D.new()
		var key_width = 1.0 * width / keys
		add_child(area)
		area.add_child(sprite)
		#sprite.centered = false
		sprite.texture = texture
		sprite.scale = Vector2(key_width, height) / 128
		sprite.global_position = global_position + Vector2(key_width * key, 0)
		area.add_child(collision_shape)
		var rectangle_shape = RectangleShape2D.new()
		rectangle_shape.size = Vector2(key_width, height)
		collision_shape.shape = rectangle_shape
		collision_shape.global_position = global_position + Vector2(key_width * key, 0)
		area.body_entered.connect(_on_body_entered.bind(key))
		area.body_exited.connect(_on_body_exited.bind(key))

func _on_body_entered(body: Node2D, key: int) -> void:
	var player = body as Player
	if player:
		#_players_inside.push_back(player)
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = audio_stream
		audio_player.bus = "SFX"
		audio_player.volume_db = 24
		audio_player.pitch_scale = 1 + 1.0 * key / keys
		add_child(audio_player)
		audio_player.play()
		await audio_player.finished
		audio_player.queue_free()
		#_audio_player_map[key] = audio_player
		#_audio_map[player] = audio_player


func _on_body_exited(body: Node2D, key: int) -> void:
	var player = body as Player
	if player:
		#_players_inside.erase(player)
		if _audio_player_map.has(key):
			var audio_player = _audio_player_map[key]
			if audio_player:
				_audio_player_map.erase(key)
				#_audio_map.erase(player)
				audio_player.queue_free()

#func _physics_process(_delta: float) -> void:
	#for player in _players_inside:
		#if _audio_map.has(player):
			#var audio_player = _audio_map[player]
			#if player.velocity.length_squared() > 10:
				#if not audio_player.playing:
					#audio_player.play()
			#else:
				#if audio_player.playing:
					#audio_player.stop()
