extends Node2D

const WORLD = preload("res://World.gd")

func _ready():
	var parent = get_parent()
	
	if parent is WORLD:
		parent.current_level = self


func _on_VisibilityNotifier2D_screen_exited():
	pass
