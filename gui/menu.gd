extends Node2D

enum ACTION_TYPES {CONTINUE, EXIT}

var options
var current = 0

func _ready():
	modulate.a = 0
	options = $line.get_children()
	options[current].active()


func show_menu():
	$anim_player.play("Open")

func hide_menu():
	$anim_player.play("Close")
	
func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		var prev = current
		if current > 0:
			current -= 1
		else:
			current = $line.get_child_count() - 1
		options[prev].inactive()
		options[current].active()

	elif Input.is_action_just_pressed("ui_down"):
		var prev = current
		if current < $line.get_child_count() - 1:
			current += 1
		else:
			current = 0
		options[prev].inactive()
		options[current].active()

	elif Input.is_action_just_pressed("ui_accept"):
		match options[current].action:
			CONTINUE:
				$"../..".close_menu()
			EXIT:
				get_tree().quit()

