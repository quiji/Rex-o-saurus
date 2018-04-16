extends Area2D

const MAX_DISTANCE = 160
const MAX_DURATION = 2.5

var direction = 1
var distance
var duration
var start_position
var t = 0

func _ready():
	add_to_group("bullets")
	connect("body_entered", self, "on_body_entered")
	$ground.cast_to += Vector2(0, rand_range(-4, 16))

func on_body_entered(body):
	
	if body.get_class() != "KinematicBody2D":

		rotation = PI * 0.2657 * direction

		dismiss(false)
	elif body.get_class() == "KinematicBody2D" and body.has_method("damage_structure"):
		dismiss()

func get_damage():
	return 15

func dismiss_by_roar():
	set_physics_process(false)
	$sprite.dismiss()


func dismiss(diagonal=true):
	if diagonal:
		rotation = -PI * 0.1057 * direction

	$hit.play()
	set_physics_process(false)
	$sprite.dismiss()

func throw(new_direction):
	direction = new_direction
	if direction < 0:
		$sprite.flip(true)
	var random_factor = rand_range(0.6, 1.0)
	distance = MAX_DISTANCE * random_factor
	duration = MAX_DURATION * random_factor
	start_position = position
	$throw.play()

	
func _physics_process(delta):
	
	t += delta / duration 

	position = start_position + Vector2(MAX_DISTANCE * t * direction, -MAX_DISTANCE * Smoothstep.arch(t))

	if t > 0.5 and not $ground.enabled:
		$ground.enabled = true
	
	if $ground.is_colliding():
		on_body_entered($ground.get_collider())
