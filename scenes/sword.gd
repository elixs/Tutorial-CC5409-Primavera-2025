extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $"../../MultiplayerSynchronizer"

var data: Statics.PlayerData = null
var initial_rotation = global_rotation_degrees

func _ready() -> void:
	
	if data:
		setup(data)


func _physics_process(delta: float) -> void:
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
	var tween = create_tween()
	tween.tween_property(self, "global_rotation_degrees", initial_rotation - 70, 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_rotation_degrees", initial_rotation + 20, 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_rotation_degrees", initial_rotation, 0.1)
