extends KinematicBody2D

var SoldierA = preload("res://enemies/soldier_a.tscn")


func _ready():
	$timer.connect("timeout", self, "on_timeout")



func on_timeout():
	var soldier = SoldierA.instance()
	soldier.position = position + $spawn.position
	get_parent().add_child(soldier)
	soldier.ai_transit_to(soldier.RUN_TO_ATTACK_DISTANCE)
