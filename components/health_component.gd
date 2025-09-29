class_name HealthComponent
extends MultiplayerSynchronizer

signal health_changed(value)

@export var health = 100:
	set(value):
		health = value
		health_changed.emit(health)
@export var max_health  = 100


func set_health(value):
	set_health_authority.rpc_id(get_multiplayer_authority(), value)


@rpc("any_peer", "call_local", "reliable")
func set_health_authority(value):
	health = value
