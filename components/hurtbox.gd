class_name Hurtbox
extends Area2D

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
		#if owner.has_method("take_damage"):
			#owner.take_damage(hitbox.damage)
