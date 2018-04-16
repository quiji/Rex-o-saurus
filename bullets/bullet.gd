extends Area2D

enum BULLET_TYPE {KNIFE, RIFLE, MACHINE_GUN  }

const RIFLE_BULLET_SPEED = 290
const MACHINE_GUN_BULLET_SPEED = 340


var direction = 1
var velocity = Vector2()
var bullet_type = 0

func _ready():
	add_to_group("bullets")
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	
	if body.get_class() != "KinematicBody2D":
		dismiss()
	elif body.get_class() == "KinematicBody2D" and body.has_method("bulleted"):
		body.bulleted(get_damage() / 15, [global_position])

		dismiss()
	
func get_damage():
	if bullet_type:
		return 30
	else:
		return 20

func dismiss_by_roar():
	set_physics_process(false)
	$sprite.dismiss()
	
func dismiss():
	
	$hit.play()
	set_physics_process(false)
	$sprite.dismiss()

func fly(new_direction, weapon):
	direction = new_direction
	
	var random_factor = 0
	var speed = 0
	if weapon == RIFLE:
		random_factor = rand_range(-0.05, 0.05)
		speed = RIFLE_BULLET_SPEED * rand_range(0.9, 1.1)
		$shot.play()

	elif weapon == MACHINE_GUN:
		random_factor = rand_range(-0.1, 0.1)
		speed = MACHINE_GUN_BULLET_SPEED * rand_range(0.8, 1.2)
		$machine_gun_shot.play()
	
	bullet_type = weapon
	
	if direction < 0:
		velocity = Vector2(-1, random_factor)
	else:
		$sprite.flip(true)
		velocity = Vector2(1, random_factor)
	velocity *= speed
	
func _physics_process(delta):
	
	position += velocity * delta
