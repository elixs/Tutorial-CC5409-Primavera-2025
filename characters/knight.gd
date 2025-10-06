class_name Knight
extends Player

@export var swing_sound: AudioStream


@onready var swing_player: AudioStreamPlayer2D = $SwingPlayer
@onready var sword: Sword = $WeaponPivot/Sword


func setup(player_data: Statics.PlayerData):
	super.setup(player_data)
	sword.setup(player_data)


func melee() -> void:
	super.melee()
	swing.rpc()


@rpc("authority", "call_local", "reliable")
func swing():
	sword.swing()
	
