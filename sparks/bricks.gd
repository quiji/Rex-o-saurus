extends Particles2D


func _ready():
	set_process(false)
	

func start(strength):
	emitting = true
	if strength == 0:
		amount = 2
		process_material.scale = 0.2
	else:
		process_material.scale = 0.25 * (strength + 1)
		amount = 5 * (strength + 1)
	set_process(true)

func _process(delta):
	if not emitting:
		queue_free()
