extends KinematicBody2D

var Knife = preload("res://bullets/knife.tscn")
var Bullet = preload("res://bullets/bullet.tscn")

enum WEAPON_TYPES {KNIFE, RIFLE, MACHINE_GUN}
enum ROW_POSITON {BACK_ROW, BACK_MIDDLE_ROW, MIDDLE_ROW, FRONT_MIDDLE_ROW, FRONT_ROW}
export (int, "Knife", "Rifle", "MachineGun") var weapon = 0

export (int, "Back", "BackMiddle", "Middle", "FrontMiddle", "Front") var people_row = 1

const MIDDLE_ROW_OFFSET = Vector2(-16, -20)
const BACK_ROW_OFFSET = Vector2(-12, -16) + Vector2(0, -20)
const FRONT_ROW_OFFSET = Vector2(-8, 16) + Vector2(0, -20)
const BACK_MIDDLE_ROW_OFFSET = Vector2(-4, -8) + Vector2(0, -20)
const FRONT_MIDDLE_ROW_OFFSET = Vector2(0, 8) + Vector2(0, -20)

const KNIFE_DISTANCE_TO_SPOT = 250
const KNIFE_DISTANCE_TO_ATTACK = 140
const KNIFE_DISTANCE_TO_RUN  = 60
const KNIFE_MAX_RUN_VELOCITY = 75.0

const RIFLE_DISTANCE_TO_SPOT = 250
const RIFLE_DISTANCE_TO_ATTACK = 220
const RIFLE_DISTANCE_TO_RUN  = 90
const RIFLE_MAX_RUN_VELOCITY = 65.0

const MACHINE_GUN_DISTANCE_TO_SPOT = 250
const MACHINE_GUN_DISTANCE_TO_ATTACK = 200
const MACHINE_GUN_DISTANCE_TO_RUN  = 100
const MACHINE_GUN_MAX_RUN_VELOCITY = 80.0


######## Const Stats #########
var max_run_velocity = 75.0
var midair_move_velocity = 20
var max_x_distance_a_jump = 30.0
var max_x_distance_b_jump = 30.0
var jump_peak_height = 50


######## Calculated Stats #########
var jump_initial_velocity_scalar = 0.0
var time_to_peak_of_jump = 0
var gravity_scalar = 0.0

var velocity = Vector2()
var run_velocity = 0
var midair_velocity = 0
var prev_y_velocity = 0

######## AI States #########
enum AIStates {IDLE, RUN_TO_ATTACK_DISTANCE, ATTACK, RUN_AWAY, SCARED, TREMBLE, ESCAPE, IDLE, OUT_LEFT, OUT_RIGHT, GOING_TO_ROW}
const TRANSITION_DURATION = 0.8
var ai_state = IDLE
var ai_transition = null
var transition_delta = 0

var on_ground = false
var falling = false
var running = false
var jumping = false

var direction = 1

const TREMBLE_DURATION = 1.25
var tremble_delta = null

const ESCAPE_DURATION = 5.0
var escape_delta = null


var step_delta = 0
var step_duration = 0.540 * 0.7
var jump_delta = 0

var current_normal = null

var throw_point = Vector2(10, -16)
var shoot_point = Vector2(12, -12)
var machine_shoot_point = Vector2(12, -8)
var distance_to_attack
var distance_to_run
var distance_to_spot
var react_factor

var whipped = false

var run_time_after_spawn = 1.8

const TIME_TO_ROW = 1.8
var delta_to_row = 0
var sprite_base_pos = Vector2()
var visiblity_notifier

func _ready():
	add_to_group("soldiers")

	$sprite.idle()
	time_to_peak_of_jump = max_x_distance_a_jump / max_run_velocity
	jump_initial_velocity_scalar = 2*jump_peak_height / time_to_peak_of_jump

	gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_b_jump*max_x_distance_b_jump)

	react_factor = rand_range(0.85, 1.15)

	match weapon:
		KNIFE:
			distance_to_attack = KNIFE_DISTANCE_TO_ATTACK * KNIFE_DISTANCE_TO_ATTACK * rand_range(0.95, 1.05)
			distance_to_run = KNIFE_DISTANCE_TO_RUN * KNIFE_DISTANCE_TO_RUN * rand_range(0.95, 1.05)
			distance_to_spot = KNIFE_DISTANCE_TO_SPOT * KNIFE_DISTANCE_TO_SPOT * rand_range(0.95, 1.05)
			max_run_velocity = KNIFE_MAX_RUN_VELOCITY * react_factor
		RIFLE:
			distance_to_attack = RIFLE_DISTANCE_TO_SPOT * RIFLE_DISTANCE_TO_SPOT * rand_range(0.95, 1.05)
			distance_to_run = RIFLE_DISTANCE_TO_RUN * RIFLE_DISTANCE_TO_RUN * rand_range(0.95, 1.05)
			distance_to_spot = RIFLE_DISTANCE_TO_SPOT * RIFLE_DISTANCE_TO_SPOT * rand_range(0.95, 1.05)
			max_run_velocity = RIFLE_MAX_RUN_VELOCITY * react_factor
		MACHINE_GUN: 
			distance_to_attack = MACHINE_GUN_DISTANCE_TO_SPOT * MACHINE_GUN_DISTANCE_TO_SPOT * rand_range(0.95, 1.05)
			distance_to_run = MACHINE_GUN_DISTANCE_TO_RUN * MACHINE_GUN_DISTANCE_TO_RUN * rand_range(0.95, 1.05)
			distance_to_spot = MACHINE_GUN_DISTANCE_TO_SPOT * MACHINE_GUN_DISTANCE_TO_SPOT * rand_range(0.95, 1.05)
			max_run_velocity = MACHINE_GUN_MAX_RUN_VELOCITY * react_factor

	$timer.connect("timeout", self, "on_timeout")

	sprite_base_pos = $sprite.position
	$sprite.position += get_people_row_offset()

	visiblity_notifier = VisibilityNotifier2D.new()
	add_child(visiblity_notifier)


func get_people_row_offset():
	match people_row:
		BACK_ROW:
			return BACK_ROW_OFFSET
		BACK_MIDDLE_ROW:
			return BACK_MIDDLE_ROW_OFFSET
		MIDDLE_ROW:
			return MIDDLE_ROW_OFFSET
		FRONT_MIDDLE_ROW:
			return FRONT_MIDDLE_ROW_OFFSET
		FRONT_ROW:
			return FRONT_ROW_OFFSET
		_:
			return Vector2()

func on_timeout():
	queue_free()

func _physics_process(delta):

	if whipped:
		prev_y_velocity = velocity.y
		velocity.y += -gravity_scalar * delta

		var collided = move_and_collide(velocity * delta)

		if collided != null:
			$sprite.explode()
			set_physics_process(false)
		return
	if not on_ground:
		prev_y_velocity = velocity.y
		velocity.y += -gravity_scalar * delta

		if jump_delta > 0:
			jump_delta -= delta

		if jump_delta < time_to_peak_of_jump - 0.320 and jump_delta > 0:

			jump_delta = 0

		if velocity.y >= 0 and prev_y_velocity <= 0:
			#$sprite.jump_peak()
			falling = true
			jumping = false

		velocity.x = midair_velocity * direction
	elif running:

		if step_delta > 0:
			var step_t = 1 - step_delta / step_duration
			step_delta -= delta
			run_velocity = lerp(run_velocity, max_run_velocity, step_t * step_t * step_t)
			velocity.x = run_velocity * direction
		else:
			velocity.x += -velocity.x * 0.05
			if abs(velocity.x) < 5:
				velocity.x = 0

	take_input(delta)


	var frame_velocity = velocity
	if on_ground and not jumping:
		frame_velocity = velocity.slide(current_normal)

	move_and_slide(frame_velocity, Vector2(0, -1), 1)


	if is_valid_ground_cast():
		if not on_ground:
			$sprite.idle()
			running = false
			jumping = false
			velocity.y = 0
			velocity.x = 0
		on_ground = true
		falling = false
	else:
		if not jumping and not falling:
			falling = true
			midair_velocity = run_velocity
			$sprite.fall()
		on_ground = false

	if $castle_ray.is_colliding() and $castle_ray.get_collider().has_method("add_soldier") and can_enter_castle():
		if $castle_ray.get_collider().add_soldier(weapon):
			queue_free()

func is_valid_ground_cast():
	var valid = $ground_ray.is_colliding() and $ground_ray.get_collision_normal().dot(Vector2(0, -1)) > 0.4

	if $ground_ray.is_colliding():
		current_normal = $ground_ray.get_collision_normal()
	else:
		current_normal = Vector2(0, -1)

	return valid



func add_step_impulse():
	if running:
		step_delta = step_duration


func jump():
	midair_velocity = run_velocity
	velocity.y = -jump_initial_velocity_scalar
	jump_delta = time_to_peak_of_jump

func is_on_ground():
	return on_ground

func run():
	running = true
	velocity.x = max_run_velocity * 0.65  * direction
	$sprite.run()

func roar_scared():
	if visiblity_notifier.is_on_screen():
		ai_transit_to(SCARED, true)

func stomped(strength=0, poss=[]):
	
	#if people_row == MIDDLE_ROW or people_row == BACK_MIDDLE_ROW or people_row == FRONT_MIDDLE_ROW:
	if $timer.is_stopped():
		$grunts.dead()
		$sprite.stomped()
	
		set_physics_process(false)
		$timer.start()
		if $sprite.has_node("timer"):
			$sprite/timer.stop()
		
	return true

	#return false


func castle_destroyed():
	if $sprite.is_stomped():
		$timer.stop()
		queue_free()

func whipped(whip_direction, poss=[]):
	if not $timer.is_stopped():
		return
	$grunts.dead()
	$sprite.whipped()
	velocity = Vector2(whip_direction, -1) * 300 * rand_range(0.8, 1.2)
	whipped = true
	jumping = true
	falling = false
	return true

func throw():
	$sprite.idle()
	var new_knife = Knife.instance()
	var throw_offset = throw_point 
	throw_offset.x *= direction
	throw_offset += get_people_row_offset()
	new_knife.position = position + throw_offset + Vector2(rand_range(-2, 2), rand_range(-2, 2))
	new_knife.throw(direction)
	$"../../bullets".add_child(new_knife)

func shoot():

	var new_bullet = Bullet.instance()
	var shoot_offset = shoot_point
	
	if weapon == MACHINE_GUN:
		shoot_offset = machine_shoot_point
	
	shoot_offset.x *= direction
	shoot_offset += get_people_row_offset()
	new_bullet.position = position + shoot_offset
	var y_variation = 0

	match people_row:
		BACK_ROW:
			 y_variation = 3
		BACK_MIDDLE_ROW:
			 y_variation = 2
		FRONT_MIDDLE_ROW:
			 y_variation = -2
		FRONT_ROW:
			 y_variation = -3
	
	new_bullet.fly(direction, weapon)
	$"../../bullets".add_child(new_bullet)


func look_right(is_right=true):
	if is_right:
		direction = 1
		$sprite.flip(false)
		$castle_ray.cast_to = Vector2(6, 0)
	else:
		direction = -1
		$sprite.flip(true)
		$castle_ray.cast_to = Vector2(-6, 0)

func ai_transit_to(new_state, no_transition = false):
	ai_transition = new_state
	if no_transition:
		transition_delta = 0
	else:
		transition_delta = TRANSITION_DURATION * react_factor

func can_enter_castle():
	return ai_state == RUN_TO_ATTACK_DISTANCE or ai_state == RUN_AWAY or ai_state == ESCAPE

func run_to_row(row, direction):
	people_row = row
	ai_transit_to(GOING_TO_ROW, true)
	look_right(direction == 1)

func rex_is_dead():
	ai_transit_to(IDLE)

func take_input(delta):
	var rex_distance = $"../../rex".position - position
	var rex_distance_squared = rex_distance.length_squared()
	var rex_direction = rex_distance.normalized()


	if ai_transition != null and transition_delta > 0:
		if $sprite.is_throwing():
			return

		if rex_distance_squared < distance_to_run:
			ai_transit_to(RUN_AWAY, true)

		transition_delta -= delta
		return
	elif ai_transition != null:
		ai_state = ai_transition
		ai_transition = null




	match ai_state:
		OUT_LEFT:
			look_right(false)
			if not running:
				run()
			run_time_after_spawn -= delta
			if run_time_after_spawn <= 0:
				ai_transit_to(IDLE, true)

		OUT_RIGHT:
			look_right(true)
			if not running:
				run()
			run_time_after_spawn -= delta
			if run_time_after_spawn <= 0:
				ai_transit_to(IDLE, true)

		GOING_TO_ROW:
			if not running:
				run()
			
			delta_to_row += delta
			var t = delta_to_row / TIME_TO_ROW
			if t > 1:
				ai_transit_to(ATTACK, true)
			else:
				$sprite.position = sprite_base_pos + MIDDLE_ROW_OFFSET.linear_interpolate(get_people_row_offset(), t)

		RUN_TO_ATTACK_DISTANCE:
			if $sprite.is_throwing():
				return

			look_right(rex_distance.x > 0)

			if not running:
				run()

			if rex_distance_squared > distance_to_attack:
				return
			elif rex_distance_squared > distance_to_run:
				ai_transit_to(ATTACK, true)
			else:
				ai_transit_to(RUN_AWAY, true)
		ATTACK:

			# If on range, attack
			look_right(rex_distance.x > 0)

			running = false
			velocity.x = 0
			if weapon == KNIFE:
				$sprite.throw()
				if rex_distance_squared > distance_to_attack:
					ai_transit_to(RUN_TO_ATTACK_DISTANCE)
				elif rex_distance_squared > distance_to_run:
					ai_transit_to(ATTACK)
				else:
					ai_transit_to(RUN_AWAY, true)
			elif rex_direction.dot(Vector2(0, -1)) < 0.25:
				$sprite.shoot_straight()
			else:
				$sprite.throw()
				if rex_distance_squared > distance_to_attack:
					ai_transit_to(RUN_TO_ATTACK_DISTANCE)
				elif rex_distance_squared > distance_to_run:
					ai_transit_to(ATTACK)
				else:
					ai_transit_to(RUN_AWAY, true)

		RUN_AWAY:
			# If too close, run away
			look_right(rex_distance.x < 0)

			if not running:
				run()

			if rex_distance_squared > distance_to_attack:
				ai_transit_to(RUN_TO_ATTACK_DISTANCE)
			elif rex_distance_squared > distance_to_run:
				ai_transit_to(ATTACK)
			else:
				ai_transit_to(RUN_AWAY, true)

		SCARED:
			$sprite.scared()
			running = false
			velocity.x = 0
		TREMBLE:
			if tremble_delta == null:
				tremble_delta = TREMBLE_DURATION * rand_range(0.8, 1.3)
			elif tremble_delta > 0:
				tremble_delta -= delta
			else:
				tremble_delta = null
				ai_transit_to(ESCAPE, true)
		ESCAPE:
			look_right(rex_distance.x < 0)

			if not running:
				run()

			if escape_delta == null:
				escape_delta = ESCAPE_DURATION * rand_range(0.8, 1.3)
			elif escape_delta > 0:
				escape_delta -= delta
			else:
				escape_delta = null
				ai_transit_to(IDLE, true)

		IDLE:
			$sprite.idle()
			if rex_distance_squared < distance_to_spot:
				ai_transit_to(RUN_TO_ATTACK_DISTANCE)

