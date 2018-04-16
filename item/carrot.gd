extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var velocity = Vector2()

func _ready():
	velocity = Vector2(0.3, -1) * 150
	$eat_area.connect("body_entered", self, "on_eaten")
	$timer.connect("timeout", self, "on_timeout")

func _physics_process(delta):
	
	velocity -= -Vector2(0, 120) * delta
	
	move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		set_physics_process(false)
	
func on_timeout():
	$eat_area.monitoring = true
	
func on_eaten(by_who):
	by_who.carrot()
	queue_free()
