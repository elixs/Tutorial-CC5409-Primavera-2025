extends Node2D

@export var player_scene: PackedScene
@export var knight_scene: PackedScene


@onready var players: Node2D = %Players
@onready var markers: Node2D = %Markers
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var joke: Label = %Joke
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	start_dialogue()
	quit_button.pressed.connect(func(): get_tree().quit())
	canvas_layer.hide()
	http_request.request_completed.connect(_on_request_completed)
	var result = http_request.request("https://official-joke-api.appspot.com/random_joke")
	if result != OK:
		Debug.log("Something went wrong with the API")
	
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


func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	canvas_layer.show()
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	joke.text = response.setup + "\n" + response.punchline
	await get_tree().create_timer(5).timeout
	canvas_layer.hide()


func start_dialogue() -> void:
	await get_tree().create_timer(3).timeout
	#Dialogic.start("timeline")
