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


func on_body_entered(body):
	
	if body.get_class() == "StaticBody2D":
		dismiss()
	

func dismiss():
	queue_free()

func throw(new_direction):
	direction = new_direction
	if direction < 0:
		$sprite.flip(true)
	var random_factor = rand_range(0.6, 1.0)
	distance = MAX_DISTANCE * random_factor
	duration = MAX_DURATION * random_factor
	start_position = position
	

	
func _physics_process(delta):
	
	t += delta / duration 
	
	
	position = start_position + Vector2(MAX_DISTANCE * t * direction, -MAX_DISTANCE * Smoothstep.arch(t))

	
