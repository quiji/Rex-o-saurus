extends KinematicBody2D

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


var on_ground = false
var falling = false
var running = false
var jumping = false

var direction = 1

var step_delta = 0
var step_duration = 0.540 * 0.7
var jump_delta = 0

var current_normal = null


func _ready():
	
	$sprite.idle()
	time_to_peak_of_jump = max_x_distance_a_jump / max_run_velocity
	jump_initial_velocity_scalar = 2*jump_peak_height / time_to_peak_of_jump

	gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_b_jump*max_x_distance_b_jump)
	

func _physics_process(delta):

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
			#$sprite.fall()
		on_ground = false
	
	

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


func take_input(delta):
	#direction = -1
	#$sprite.flip(true)
	if not running:
		run()
	#$sprite.flip(true)
