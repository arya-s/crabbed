extends Node2D

var ExplosionEffect = preload("res://Explosion.tscn")

var velocity = Vector2.ZERO

func _ready():
	set_process(false)

func _process(delta):
	position += velocity * delta

func create_explosion():
	var explosion = Utils.instance_scene_on_main(ExplosionEffect, global_position)
	explosion.rotation = rotation

# warning-ignore:unused_argument
func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()


# warning-ignore:unused_argument
func _on_Hitbox_body_entered(body):
	create_explosion()
	queue_free()


func _on_Hitbox_area_entered(area):
	create_explosion()
	queue_free()
