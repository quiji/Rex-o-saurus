extends Node2D

var current_anim = ''

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func idle():
	play("Idle")
	
	
func play(anim):
	if current_anim != anim:
		current_anim = anim
		$anim_player.play(anim)

