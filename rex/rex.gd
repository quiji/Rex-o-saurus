extends KinematicBody2D


######## Const Stats #########
var max_run_velocity = 220 #150.0
var midair_move_velocity = 190#60.0
var max_x_distance_a_jump = 115.0
var max_x_distance_b_jump = 125.0
var jump_peak_height = 150


######## Calculated Stats #########
var jump_initial_velocity_scalar = 0.0
var time_to_peak_of_jump = 0

var highgest_gravity_scalar = 0.0
var lowest_gravity_scalar = 0.0
var fall_gravity_scalar = 0.0

var velocity = Vector2()
var run_velocity = 0
var prev_y_velocity = 0


var on_ground = false
var falling = false
var running = false

var direction = 1

var step_delta = 0
var step_duration = 0.620 * 0.7
var jump_delta = 0

var current_gravity = 0


func _ready():
	$sprite.idle()
	
	time_to_peak_of_jump = max_x_distance_a_jump / max_run_velocity
	jump_initial_velocity_scalar = 2*jump_peak_height / time_to_peak_of_jump

	fall_gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_b_jump*max_x_distance_b_jump)
	lowest_gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_a_jump*max_x_distance_a_jump)
	highgest_gravity_scalar = lowest_gravity_scalar * 6
	current_gravity = fall_gravity_scalar
	
	Console.add_log("highgest_gravity_scalar", highgest_gravity_scalar)
	Console.add_log("lowest_gravity_scalar", lowest_gravity_scalar)
	Console.add_log("fall_gravity_scalar", fall_gravity_scalar)

func _physics_process(delta):
	
	if not on_ground:
		prev_y_velocity = velocity.y
		velocity.y += -current_gravity * delta
		
		if jump_delta > 0:
			jump_delta -= delta

		if jump_delta < time_to_peak_of_jump - 0.320 and jump_delta > 0:
			$sprite.jump_peak()
			jump_delta = 0
	
		if velocity.y >= 0 and prev_y_velocity <= 0:
			falling = true
			current_gravity = fall_gravity_scalar
	
	Console.add_log("jump_delta", jump_delta)
	
	if step_delta > 0:
		var step_t = 1 - step_delta / step_duration
		step_delta -= delta
		run_velocity = lerp(run_velocity, max_run_velocity, step_t * step_t * step_t)
		velocity.x = run_velocity * direction
	else:
		velocity.x += -velocity.x * 0.25
		if abs(velocity.x) < 5:
			velocity.x = 0

	take_input(delta)
	
	move_and_slide(velocity, Vector2(0, -1))
	
	if $ground_ray.is_colliding():
		if not on_ground:
			$sprite.land()
		on_ground = true
		falling = false
	else:
		on_ground = false
		if velocity.y >= 0:
			falling = true
	
	Console.add_log("current_gravity", current_gravity)

func add_step_impulse():
	step_delta = step_duration

func jump():
	velocity.y = -jump_initial_velocity_scalar
	jump_delta = time_to_peak_of_jump

func take_input(delta):
	var left_jp = Input.is_action_just_pressed("ui_left")
	var left_p = Input.is_action_pressed("ui_left")
	var left_jr = Input.is_action_just_released("ui_left")
	var right_jp = Input.is_action_just_pressed("ui_right")
	var right_p = Input.is_action_pressed("ui_right")
	var right_jr = Input.is_action_just_released("ui_right")
	var jump_jp = Input.is_action_just_pressed("jump")
	var jump_jr = Input.is_action_just_released("jump")
	

	if left_p:
		$sprite.flip(true)
		direction = -1
	elif right_p:
		$sprite.flip(false)
		direction = 1
	
	if (left_p or right_p) and on_ground and not running:
		$sprite.run()
		running = true
		velocity.x = max_run_velocity * 2 * direction
	elif (left_jr or right_jr) and on_ground:
		$sprite.idle()
		running = false
		run_velocity = 0
		if step_delta >= step_duration * 0.5:
			step_delta = 0
	
	if (left_p or right_p) and not on_ground:
		velocity.x
	
	if jump_jp and on_ground:
		$sprite.start_jump()
		current_gravity = lowest_gravity_scalar
	
	if jump_jr and not falling:
		current_gravity = highgest_gravity_scalar
