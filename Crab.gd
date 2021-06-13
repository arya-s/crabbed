extends Node2D

onready var animator = $AnimationPlayer

var velocity = Vector2.ZERO

func _process(delta):
	position += velocity * delta
