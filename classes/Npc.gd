extends Node2D

var can_talk = false
var talking = false

func _ready():
	$sprite/anim_player.play("Idle")

	$talk_area.connect("body_entered", self, "on_rex_can_talk")
	$talk_area.connect("body_exited", self, "on_rex_cannot_talk")
	$anim_player.connect("animation_finished", self, "on_anim_finished")
	$message_box.connect("finished_message", self, "on_finished_message")
	$timer.connect("timeout", self, "on_can_talk_again")
	
func on_rex_can_talk(body):
	$anim_player.play("Appear")
	can_talk = true
	

func on_rex_cannot_talk(body):
	$anim_player.play("Disappear")
	can_talk = false
	
	if talking:
		on_finished_message()

func on_anim_finished(anim):
	if anim == "Appear":
		$anim_player.play("indicator")


func _input(event):
	if Input.is_action_just_pressed("ui_up") and can_talk and not talking:
		
		var rex_distance = $"../../rex".position - position
		var rex_direction = rex_distance.normalized()
		$sprite/sprite.flip_h = rex_distance.x < 0
		$sprite/anim_player.play("Hello")

		$message_box.show_text(["Hello Stranger!", "Beautiful day isn't it?"])
		talking = true
		$"../../rex".talking($message_box.global_position)


func on_finished_message():
	$sprite/anim_player.play_backwards("Hello")
	$message_box.close()
	$timer.start()

func on_can_talk_again():
	talking = false
	$"../../rex".no_talking()
