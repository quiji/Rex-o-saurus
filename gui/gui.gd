extends CanvasLayer



func update_health(health, hit=true):
	$health.value = health

	if hit:
		$health/anim_player.play("Hurt")
	else:
		$health/anim_player.play("Healed")

var experience = 0
func add_exp(n):
	experience += n
	$exp_label.show()
	$exp_label.text = str(experience) + " Exp. Points"

func open_menu():
	$menus/menu.show_menu()
	get_tree().paused = true
	get_parent().fade_out()

func close_menu():
	$menus/menu.hide_menu()
	get_tree().paused = false
	get_parent().fade_in()
	
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if not get_tree().paused:
			open_menu()

