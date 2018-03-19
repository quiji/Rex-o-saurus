extends Node2D

enum ReactTypes {NO_REACTION, STEP_REACTION}

var current_anim = ''

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func idle():
	play("Idle")

func run():
	play("Run")

func react(action):
	match action:
		STEP_REACTION:
			get_parent().add_step_impulse()
	
func play(anim):
	if current_anim != anim:
		current_anim = anim
		$anim_player.play(anim)

func flip(left=true):
	$sprite.flip_h = left