class_name Knight
extends Player

@export var swing_sound: AudioStream

@onready var swing_player: AudioStreamPlayer2D = $SwingPlayer

@onready var sword: Node2D = $WeaponPivot/Sword




func setup(player_data: Statics.PlayerData):
	super.setup(player_data)
	sword.setup(player_data)
	
func melee() -> void:
	swing.rpc()


@rpc("authority", "call_local", "reliable")
func swing():
	sword.swing()
	#AudioManager.play_sound(swing_sound)
	swing_player.play()
