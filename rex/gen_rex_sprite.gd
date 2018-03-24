extends Node2D

enum ReactTypes {NO_REACTION, STEP_REACTION, ROAR_REACTION}

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
	if current_anim != "Whip":
		play("JumpPeak")

func whip():
	play("Whip")

func is_whipping():
	return current_anim == "Whip"

func roar():
	play("Roar")

func land():
	if current_anim != "Whip":
		play("Land")

func hard_land():
	if current_anim != "Whip":
		play("HardLand")


func is_landing():
	return current_anim == "Land" or current_anim == "HardLand"

func fall():
	play("Fall")

func react(action):
	match action:
		STEP_REACTION:
			get_parent().add_step_impulse()
		ROAR_REACTION:
			get_parent().roar()
	
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
		"HardLand":
			play("Idle")
		"Whip":
			if get_parent().is_on_ground():
				play("Idle")
			else:
				play("Fall")
		"Roar":
			play("Idle")
			get_parent().bullet_dispel_on = false



