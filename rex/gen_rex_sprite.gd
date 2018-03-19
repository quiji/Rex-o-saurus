extends Node2D

enum ReactTypes {NO_REACTION, STEP_REACTION}

var current_anim = ''

func _ready():
	$anim_player.connect("animation_finished", self, "on_animation_finished")

func idle():
	play("Idle")

func run():
	play("Run")

func start_jump():
	play("StartJump")

func jump_peak():
	play("JumpPeak")

func land():
	play("Land")

func fall():
	play("Fall")

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
	
func on_animation_finished(anim):
	match anim:
		"StartJump":
			play("Jump")
			get_parent().jump()
		"JumpPeak":
			play("Fall")
		"Land":
			play("Idle")

