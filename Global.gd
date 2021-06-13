extends Node

var Player
onready var respawn_timer = $RespawnTimer

# TODO: investigate camera bug when dieing and not seeing dying effect
# in single shape rooms

func _ready():
	Events.connect("player_death", self, "_on_Player_death")

func _on_Player_death():
	respawn_timer.start()

func _on_RespawnTimer_timeout():
	Utils.reset_scene()
