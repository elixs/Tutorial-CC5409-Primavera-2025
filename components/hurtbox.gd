class_name Hurtbox
extends Area2D

signal damage_recieved

@export var health_component: HealthComponent


func _ready() -> void:
	if is_multiplayer_authority():
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D):
	var hitbox = area as Hitbox
	if hitbox:
		if hitbox.should_ignore(self):
			return
		if health_component:
			health_component.set_health(health_component.health - hitbox.damage)
			#health_component.health -= hitbox.damage
			hitbox.damage_dealt.emit()
			notify_damage_received.rpc_id(owner.get_multiplayer_authority())
		#if owner.has_method("take_damage"):
			#owner.take_damage(hitbox.damage)

@rpc("reliable", "call_local")
func notify_damage_received() -> void:
	damage_recieved.emit()
