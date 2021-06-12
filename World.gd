extends Node

export(String, FILE, "Level_*.tscn") var starting_level

func _ready():
	VisualServer.set_default_clear_color(Color.black)
	get_tree().change_scene(starting_level)
