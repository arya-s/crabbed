extends Area2D

export(String, FILE, "*.tscn") var next_level = ""

var active = true

func _enter_tree():
	active = true


func _on_Goal_body_entered(player):
	if active:
		player.emit_signal("hit_goal", self)
		
		if next_level != "":
			get_tree().change_scene(next_level)
			active = false
