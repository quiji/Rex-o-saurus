extends Node2D

enum ShakeDirectionTypes {X_AXIS, Y_AXIS, ALL_DIRECTIONS}
enum ShakeMovementTypes {ARCH, STRONG_TO_LOW}

var DIRECTIONS = [Vector2(0, -1), Vector2(1, -1).normalized(), Vector2(1, 0), Vector2(1, 1).normalized(), Vector2(0, 1), Vector2(-1, 1).normalized(), Vector2(-1, 0), Vector2(-1, -1).normalized()]

var shake_delta = 0
var shake_duration = 0
var movement_duration = 0
var shake_type = ALL_DIRECTIONS
var shake_movement_type = ARCH
var amplitude = 10

func _ready():
	set_physics_process(false)
	$tween.connect("tween_completed", self, "on_talking_end")

func shake(duration, amp, shk_type, shk_mov_type):
	set_physics_process(true)
	
	total_movements = 15.0
	amplitude = amp
	shake_type = shk_type
	shake_movement_type = shk_mov_type
	shake_delta = duration + 0.5
	shake_duration = duration
	movement_duration = duration / (total_movements + 1.0)
	movement_count = 0
	movement_t = 0
	shake_t = 0
	direction = null
	start_point = $camera_man.offset
	current = $camera_man.offset
	target = _generate_new_target(0)

var direction = null
func _generate_new_target(t):
	match shake_type:
		X_AXIS:
			if direction == null:
				direction = Vector2(1, 0)
			else:
				direction *= -1
		Y_AXIS:
			if direction == null:
				direction = Vector2(0, 1)
			else:
				direction *= -1
		ALL_DIRECTIONS:
			var choosen = DIRECTIONS[randi() % 8]
			if direction == null:
				direction = choosen
			elif choosen.dot(direction) > 0.5:
				direction = choosen * -1
			else:
				direction = choosen
	if shake_movement_type == ARCH:
		return direction * lerp(0, amplitude, Smoothstep.arch(t, 4)) * rand_range(0.8, 1)
	else:
		return direction * lerp(0, amplitude, Smoothstep.flip(Smoothstep.stop4(t))) * rand_range(0.8, 1)

var talking_offset
var finishing_talk = false
func talking(pos):
	pos += Vector2(0, 15)
	talking_offset = $camera_man.offset
	$tween.interpolate_property($camera_man, "offset", talking_offset, pos, 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
	$tween.start()

func no_more_talking():

	$tween.interpolate_property($camera_man, "offset", $camera_man.offset, talking_offset, 0.8, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$tween.start()
	finishing_talk = true

func on_talking_end(object, key):
	if finishing_talk:
		get_parent().ended_talking_camera_movement()
		finishing_talk = false


var movement_t = 0
var movement_count = 0
var shake_t = 0

var total_movements = 0
var target = Vector2()
var current = Vector2()
var start_point = Vector2()
func _physics_process(delta):
	if shake_delta > 0:
		shake_delta -= delta

		if movement_t >= 1 and movement_count < total_movements:
			movement_t = 0
			current = target
			target = _generate_new_target(shake_t)
			movement_count += 1
		elif movement_t >= 1 and movement_count == total_movements:
			movement_t = 0
			current = target
			target = start_point
		$camera_man.offset = current.linear_interpolate(target, movement_t)
		shake_t += delta / shake_duration
		movement_t += delta / movement_duration
	else:
		$camera_man.offset = start_point
		set_physics_process(false)
