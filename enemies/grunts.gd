extends Node2D

func _ready():
	$timer.connect("timeout", self, "on_timeout")

func dead():
	$timer.wait_time = 0.25 * rand_range(0.1, 1)
	$timer.start()

func on_timeout():
	if randi() % 2 == 0:
		$grunt.play()
	else:
		$grunt2.play()
