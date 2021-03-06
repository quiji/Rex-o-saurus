extends Node2D

enum ReactTypes {NO_REACTION, STEP_REACTION, ROAR_REACTION, WHIP_REACTION, SHOOT_REACTION}


var current_anim = ''

func _ready():
	$anim_player.connect("animation_finished", self, "on_animation_finished")

func idle():
	play("Idle")

func run():
	play("Run")

func fall():
	play("Fall")

func throw():
	play("Throw")

func is_throwing():
	return current_anim == "Throw"

func scared():
	play("Scared")

func is_scared():
	return current_anim == "Scared" or current_anim == "Tremble"

func stomped():
	play("Stomped")

func is_stomped():
	return current_anim == "Stomped"

func explode():
	play("Explode")

func whipped():
	play("Whipped")

func shoot_straight():
	play("ShootStraight")

func react(action):
	match action:
		STEP_REACTION:
			get_parent().add_step_impulse()
		SHOOT_REACTION:
			get_parent().shoot()

	
func play(anim):
	if current_anim != anim:
		current_anim = anim
		$anim_player.play(anim)

func flip(left=true):
	$sprite.flip_h = left
	
func on_animation_finished(anim):
	match anim:
		"Throw":
			get_parent().throw()
		"Scared":
			play("Tremble")
			get_parent().ai_transit_to(get_parent().TREMBLE, true)
		"Explode":
			get_parent().on_timeout()
		"ShootStraight":
			get_parent().ai_transit_to(get_parent().IDLE)
