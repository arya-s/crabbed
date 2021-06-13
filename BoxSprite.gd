extends Node2D

func _on_Hurtbox_hit(damage):
	Events.emit_signal("box_destroyed", self)
	queue_free()
