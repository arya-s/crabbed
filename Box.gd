extends RigidBody2D

onready var collider = $Collider


func _on_Hurtbox_hit(damage):
	queue_free()
