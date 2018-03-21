extends Node2D

var shake_delta = 0

func _ready():
	set_physics_process(false)

func shake(duration):
	set_physics_process(true)
	shake_delta = duration
	
func _physics_process(delta):
	
	if shake_delta > 0:
		shake_delta -= delta
		rand_range(-1.0, 1.0)
		$camera_man.position = Vector2()
	else:
		$camera_man.position = Vector2()
