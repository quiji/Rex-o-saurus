extends CanvasLayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func update_health(health):
	$health.value = health
	Console.add_log("health", health)

var experience = 0
func add_exp(n):
	experience += n
	$exp_label.show()
	$exp_label.text = str(experience) + " Exp. Points"
