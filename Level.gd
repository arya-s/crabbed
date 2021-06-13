extends Node2D

const WORLD = preload("res://World.gd")

onready var crab = $Crab
onready var crab_timer = $CrabFallTimer

var is_crab_falling = false

export(int) var crab_fall_speed = 200

func _ready():
	var parent = get_parent()
	
	if parent is WORLD:
		parent.current_level = self		
	

func _on_CrabTrigger_area_entered(area):
	if not Global.is_crabbed:
		is_crab_falling = true
		crab.velocity = Vector2.DOWN * crab_fall_speed
		crab.get_node("AnimationPlayer").play("Fall")


func _on_Crab_body_entered(body):
	crab.queue_free()
	Global.is_crabbed = true
