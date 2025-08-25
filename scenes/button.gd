extends Node2D

@export var raft: Raft

@onready var area_2d: Area2D = $Area2D
@onready var label: Label = $Label

var players = []
var authority_players = []


func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not authority_players.is_empty():
		toggle.rpc()

func _on_body_entered(body: Node2D):
	var player = body as Player
	if player:
		players.push_back(player)
		if player.is_multiplayer_authority():
			authority_players.push_back(player)
		label.show()


func _on_body_exited(body: Node2D):
	players.erase(body)
	authority_players.erase(body)
	if players.is_empty():
		label.hide()

@rpc("any_peer", "call_local", "reliable")
func toggle():
	if raft:
		raft.toggle()
