extends Hitbox

@export var max_speed = 400


func _physics_process(delta: float) -> void:
	position += max_speed * transform.x * delta


func should_ignore(hurtbox: Hurtbox) -> bool:
	return hurtbox.owner == get_parent().owner
