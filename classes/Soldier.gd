extends KinematicBody2D

var Knife = preload("res://bullets/knife.tscn")

const DISTANCE_TO_SPOT = 250
const DISTANCE_TO_ATTACK = 140
const DISTANCE_TO_RUN  = 60

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
enum AIStates {IDLE, RUN_TO_ATTACK_DISTANCE, ATTACK, RUN_AWAY, SCARED, TREMBLE, ESCAPE, IDLE, OUT_LEFT, OUT_RIGHT}
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
var distance_to_attack
var distance_to_run 
var distance_to_spot

var whipped = false

var run_time_after_spawn = 1.8

func _ready():
	add_to_group("soldiers")
	
	$sprite.idle()
	time_to_peak_of_jump = max_x_distance_a_jump / max_run_velocity
	jump_initial_velocity_scalar = 2*jump_peak_height / time_to_peak_of_jump

	gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_b_jump*max_x_distance_b_jump)

	distance_to_attack = DISTANCE_TO_ATTACK * DISTANCE_TO_ATTACK * rand_range(0.7, 1.5)
	distance_to_run = DISTANCE_TO_RUN * DISTANCE_TO_RUN * rand_range(0.7, 1.5)
	distance_to_spot = DISTANCE_TO_SPOT * DISTANCE_TO_SPOT * rand_range(0.7, 1.5)

	max_run_velocity = max_run_velocity * rand_range(0.3, 2)

	$timer.connect("timeout", self, "on_timeout")

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
		if $castle_ray.get_collider().add_soldier():
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
	ai_transit_to(SCARED, true)

func stomped(strength=0):
	$sprite.stomped()
	set_physics_process(false)
	$timer.start()

func whipped(whip_direction):
	if not $timer.is_stopped():
		return
	$sprite.whipped()
	velocity = Vector2(whip_direction, -1) * 300 * rand_range(0.8, 1.2)
	whipped = true
	jumping = true
	falling = false


func throw():
	$sprite.idle()
	var new_knife = Knife.instance()
	var throw_offset = throw_point
	throw_offset.x *= direction
	new_knife.position = position + throw_offset + Vector2(rand_range(-2, 2), rand_range(-2, 2))
	new_knife.throw(direction)
	$"../../bullets".add_child(new_knife)

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
		transition_delta = TRANSITION_DURATION * rand_range(0.8, 1.3)

func can_enter_castle():
	return ai_state == RUN_TO_ATTACK_DISTANCE or ai_state == RUN_AWAY or ai_state == ESCAPE

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

