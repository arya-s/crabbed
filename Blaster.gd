extends Node2D

var Rocket = preload("res://Rocket.tscn")

export(Vector2) var rocket_velocity = Vector2.RIGHT
export(int) var rocket_speed = 100

onready var timer = $Timer
onready var muzzle = $Muzzle

func fire():
	var bullet = Utils.instance_scene_on_main(Rocket, muzzle.global_position)
	bullet.velocity = rocket_velocity * rocket_speed
	bullet.rotation = rotation

func _on_Timer_timeout():
	fire()
