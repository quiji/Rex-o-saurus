extends KinematicBody2D

const TOP_HEALTH = 4000.0

######## Const Stats #########
var max_run_velocity = 180.0
var midair_move_velocity = 140#60.0
var max_x_distance_a_jump = 160.0
var max_x_distance_b_jump = 120.0
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

var talking = false
var bullet_dispel_on = false

var direction = 1

var step_delta = 0
var step_duration = 0.620 * 0.7
var jump_delta = 0
var ground_loose_delta = 0
var ground_loose_duration = 0.4
var current_gravity = 0

var current_normal = null
var stomp_area
var whip_area_left
var whip_area_right

var health = 0.0

func _ready():
	$sprite.idle()
	
	time_to_peak_of_jump = max_x_distance_a_jump / max_run_velocity
	jump_initial_velocity_scalar = 2*jump_peak_height / time_to_peak_of_jump

	fall_gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_b_jump*max_x_distance_b_jump)
	lowest_gravity_scalar = -2*jump_peak_height* (max_run_velocity*max_run_velocity) / (max_x_distance_a_jump*max_x_distance_a_jump)
	highgest_gravity_scalar = lowest_gravity_scalar * 6
	current_gravity = fall_gravity_scalar

	$damage_area.connect("area_entered", self, "on_bullet_hit")

	stomp_area = $stomp_area/collision.shape
	whip_area_right = $tail_whip_area_right.shape_owner_get_shape(0, 0)
	whip_area_left = $tail_whip_area_left.shape_owner_get_shape(0, 0)

	health = TOP_HEALTH

func _physics_process(delta):
	
	if talking:
		return
	
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
	
	var frame_velocity = velocity
	
	if on_ground and not jumping:
		frame_velocity = velocity.slide(current_normal)

	move_and_slide(frame_velocity, Vector2(0, -1), 1)
	
	if is_valid_ground_cast():
		if not on_ground:
			var strength = 0
			if velocity.y < 230:
				$lighterland_player.play(0)
				$sprite.land()
				$camera_crew.shake(2, 1, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)
			elif velocity.y < 350:
				$lightland_player.play(0)
				$sprite.hard_land()
				$camera_crew.shake(2, 2, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)
				strength = 1
			elif velocity.y < 550:
				$land_player.play(0)
				$sprite.hard_land()
				$camera_crew.shake(1, 5, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)
				strength = 2
			else:
				$hardland_player.play(0)
				$sprite.hard_land()
				$camera_crew.shake(0.8, 8, $camera_crew.Y_AXIS, $camera_crew.STRONG_TO_LOW)
				strength = 3

			check_stomp_collision(strength)

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
	
	if bullet_dispel_on:
		get_tree().call_group("bullets", "dismiss")

func is_valid_ground_cast():
	var ray_a = $ground_ray_a.is_colliding() and $ground_ray_a.get_collision_normal().dot(Vector2(0, -1)) > 0.4
	var ray_b = $ground_ray_b.is_colliding() and $ground_ray_b.get_collision_normal().dot(Vector2(0, -1)) > 0.4
	
	var normal_a = Vector2(0, -1)
	var normal_b = Vector2(0, -1)

	if $ground_ray_a.is_colliding():
		normal_a = $ground_ray_a.get_collision_normal()

	if $ground_ray_b.is_colliding():
		normal_b = $ground_ray_b.get_collision_normal()

	if normal_a.dot(Vector2(0, -1)) < normal_b.dot(Vector2(0, -1)):
		current_normal = normal_a
	else:
		current_normal = normal_b 

	
	return ray_a or ray_b
	
func check_stomp_collision(strength):
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var query = Physics2DShapeQueryParameters.new()
	query.collision_layer = 4 # third bit
	query.margin = 0.08
	query.set_shape(stomp_area)
	query.transform = transform
	
	var result = space_state.intersect_shape(query)
	while result.size() > 0:
		var is_dead
		is_dead = result[0].collider.stomped(strength)
		if result[0].collider.has_method("roar_scared"):
			$"../gui".add_exp(2)
		else:
			if is_dead:
				$"../gui".add_exp(10)
			else:
				$"../gui".add_exp(4)
		result.pop_front()
	
func check_whip_collision():
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var query = Physics2DShapeQueryParameters.new()
	query.collision_layer = 4 # third bit
	query.margin = 0.08
	if direction > 0:
		query.set_shape(whip_area_right)
	else:
		query.set_shape(whip_area_left)
	query.transform = transform
	
	var result = space_state.intersect_shape(query)
	while result.size() > 0:
		var is_dead
		is_dead = result[0].collider.whipped(direction)
		if result[0].collider.has_method("roar_scared"):
			$"../gui".add_exp(1)
		else:
			if is_dead:
				$"../gui".add_exp(10)
			else:
				$"../gui".add_exp(2)

		result.pop_front()
		

	
func roar():
	$roar_player.play(0)
	$camera_crew.shake(1.3, 10, $camera_crew.ALL_DIRECTIONS, $camera_crew.ARCH)
	bullet_dispel_on = true
	get_tree().call_group("soldiers", "roar_scared")

func talking(pos):
	$camera_crew.talking(pos - global_position)
	talking = true

func no_talking():
	$camera_crew.no_more_talking()

func ended_talking_camera_movement():
	talking = false

func talk_direction():
	return Vector2(1, 0) * direction

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

func on_bullet_hit(bullet):
	
	health -= bullet.get_damage()
	bullet.dismiss()
	
	$"../gui".update_health(health / TOP_HEALTH)

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
	
	if bullet_dispel_on:
		return
	
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
		$damage_area/collision_left.disabled = false
		$damage_area/collision_right.disabled = true

	elif right_p:

		$sprite.flip(false)
		direction = 1
		$damage_area/collision_left.disabled = true
		$damage_area/collision_right.disabled = false
	
	if (left_p or right_p) and is_on_ground() and not running and not jumping and not $sprite.is_landing() and not $sprite.is_whipping():
		$sprite.run()
		running = true
		velocity.x = max_run_velocity * 0.65  * direction
	elif (left_jr or right_jr) and is_on_ground():
		if not $sprite.is_whipping():
			$sprite.idle()
		running = false
		run_velocity = 0
		velocity.x = 0
		if step_delta >= step_duration * 0.5:
			step_delta = 0
	
	if (left_p or right_p) and not is_on_ground():
		midair_velocity = midair_move_velocity
	
