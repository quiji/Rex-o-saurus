extends KinematicBody2D


######## Const Stats #########
var max_run_velocity = 180.0
var midair_move_velocity = 140#60.0
var max_x_distance_a_jump = 100.0
var max_x_distance_b_jump = 180.0
var jump_peak_height = 150


######## Calculated Stats #########
var jump_initial_velocity_scalar = 0.0
var time_to_peak_of_jump = 0

var highgest_gravity_scalar = 0.0
var lowest_gravity_scalar = 0.0
var fall_gravity_scalar = 0.0

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
var step_duration = 0.620 * 0.7
var jump_delta = 0
var ground_loose_delta = 0
var ground_loose_duration = 0.4
var current_gravity = 0


func _ready():
	$sprite.idle()
	
	time_to_peak_of_jump = max_x_distance_a_jump / max_run_velocity
	jump_initial_velocity_scalar = 2*jump_peak_height / time_to_peak_of_jump

	fall_gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_b_jump*max_x_distance_b_jump)
	lowest_gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_a_jump*max_x_distance_a_jump)
	highgest_gravity_scalar = lowest_gravity_scalar * 6
	current_gravity = fall_gravity_scalar
	

func _physics_process(delta):
	
	if not on_ground:
		prev_y_velocity = velocity.y
		velocity.y += -current_gravity * delta
		
		if jump_delta > 0:
			jump_delta -= delta

		if jump_delta < time_to_peak_of_jump - 0.320 and jump_delta > 0:

			jump_delta = 0
	
		if velocity.y >= 0 and prev_y_velocity <= 0:
			$sprite.jump_peak()
			falling = true
			jumping = false
			current_gravity = fall_gravity_scalar
	
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
	
	move_and_slide(velocity, Vector2(0, -1), 1)
	
	if is_valid_ground_cast():
		if not on_ground:
			if velocity.y < 230:
				$lighterland_player.play(0)
				$sprite.land()
				$camera_crew.shake(2, 2, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)
			elif velocity.y < 350:
				$lightland_player.play(0)
				$sprite.hard_land()
				$camera_crew.shake(2, 4, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)
			elif velocity.y < 550:
				$land_player.play(0)
				$sprite.hard_land()
				$camera_crew.shake(1, 10, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)
			else:
				$land_player.play(0)
				$sprite.hard_land()
				$camera_crew.shake(0.8, 15, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)

			running = false
			jumping = false
			velocity.y = 0
			velocity.x = 0
		on_ground = true
		falling = false
		ground_loose_delta = 0
	else:
		if not jumping and not falling:
			falling = true
			current_gravity = fall_gravity_scalar
			$sprite.fall()
		on_ground = false
	
	if on_ground:
		ground_loose_delta = ground_loose_duration
	elif ground_loose_delta > 0:
		ground_loose_delta -= delta
	

func is_valid_ground_cast():
	var valid = false
	var ray_a = $ground_ray_a.is_colliding() and $ground_ray_a.get_collision_normal().dot(Vector2(0, -1)) > 0.4
	var ray_b = $ground_ray_b.is_colliding() and $ground_ray_b.get_collision_normal().dot(Vector2(0, -1)) > 0.4
	if ray_a or ray_b :
		valid = true
	Console.add_log("ray_a", ray_a)
	Console.add_log("ray_b", ray_b)
	if $ground_ray_a.is_colliding():
		Console.add_log("normal_a", $ground_ray_a.get_collision_normal())
		Console.add_log("dot_a", $ground_ray_a.get_collision_normal().dot(Vector2(0, -1)))
	if $ground_ray_b.is_colliding():
		Console.add_log("normal_b", $ground_ray_b.get_collision_normal())
		Console.add_log("dot_b", $ground_ray_b.get_collision_normal().dot(Vector2(0, -1)))
	return valid
	
func roar():
	$roar_player.play(0)
	$camera_crew.shake(1.3, 10, $camera_crew.ALL_DIRECTIONS, $camera_crew.ARCH)

	
func add_step_impulse():
	if running:
		step_delta = step_duration
		$step_player.play(0)
		$camera_crew.shake(0.5, 2.5, $camera_crew.X_AXIS, $camera_crew.STRONG_TO_LOW)

func jump():
	midair_velocity = run_velocity
	velocity.y = -jump_initial_velocity_scalar
	jump_delta = time_to_peak_of_jump

func is_on_ground():
	return on_ground and ground_loose_delta > 0

func take_input(delta):
	var left_jp = Input.is_action_just_pressed("ui_left")
	var left_p = Input.is_action_pressed("ui_left")
	var left_jr = Input.is_action_just_released("ui_left")
	var right_jp = Input.is_action_just_pressed("ui_right")
	var right_p = Input.is_action_pressed("ui_right")
	var right_jr = Input.is_action_just_released("ui_right")
	var jump_jp = Input.is_action_just_pressed("jump")
	var jump_jr = Input.is_action_just_released("jump")
	var whip_jp = Input.is_action_just_pressed("whip")
	var roar_jp = Input.is_action_just_pressed("roar")
	
	if whip_jp:
		$sprite.whip()
		$whip_player.play(0)

	if roar_jp and is_on_ground() and not $sprite.is_whipping() and not jumping:
		$sprite.roar()



	if jump_jp and is_on_ground() and not $sprite.is_whipping():
		jumping = true
		running = false
		velocity.x = 0
		$sprite.start_jump()
		current_gravity = lowest_gravity_scalar
	
	if jump_jr and not falling:
		current_gravity = highgest_gravity_scalar


	if left_p:
		$sprite.flip(true)
		direction = -1
	elif right_p:
		$sprite.flip(false)
		direction = 1
	
	if (left_p or right_p) and is_on_ground() and not running and not jumping and not $sprite.is_landing() and not $sprite.is_whipping():
		$sprite.run()
		running = true
		velocity.x = max_run_velocity * 0.65  * direction
	elif (left_jr or right_jr) and is_on_ground():
		$sprite.idle()
		running = false
		run_velocity = 0
		velocity.x = 0
		if step_delta >= step_duration * 0.5:
			step_delta = 0
	
	if (left_p or right_p) and not is_on_ground():
		midair_velocity = midair_move_velocity
	
