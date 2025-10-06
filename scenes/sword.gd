class_name Sword
extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var pivot: Node2D = $Pivot
@onready var swing_audio: AudioStreamPlayer2D = $SwingAudio


var data: Statics.PlayerData = null


func _ready() -> void:
	if data:
		setup(data)


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		global_position = global_position.lerp(get_global_mouse_position(), 0.1)


func setup(player_data: Statics.PlayerData):
	if data:
		return
	if is_node_ready():
		set_multiplayer_authority(player_data.id)
		multiplayer_synchronizer.set_multiplayer_authority(player_data.id, false)
	else:
		data = player_data


func swing():
	swing_audio.play()
	var tween = create_tween()
	tween.tween_property(pivot, "rotation_degrees", -70, 0.1) \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(pivot, "rotation_degrees", 20, 0.1) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(pivot, "rotation_degrees", 0, 0.1)
