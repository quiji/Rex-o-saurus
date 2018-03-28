extends Node2D

export (int, "Rosita", "Jack", "Female_NPC", "Male_NPC", "RatKing") var text_id = 0

var can_talk = false
var talking = false
var helloed = false

var dialogue
var current_text  = 0

func _ready():
	$sprite/anim_player.play("Idle")

	$talk_area.connect("body_entered", self, "on_rex_can_talk")
	$talk_area.connect("body_exited", self, "on_rex_cannot_talk")
	$anim_player.connect("animation_finished", self, "on_anim_finished")
	$sprite/anim_player.connect("animation_finished", self, "on_character_anim_finished")
	$message_box.connect("finished_message", self, "on_finished_message")
	$timer.connect("timeout", self, "on_can_talk_again")
	
	dialogue = Glb.get_dialogue(text_id)
	
func on_rex_can_talk(body):
	$talk_indicator.position = Vector2(0, -82)
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

func on_character_anim_finished(anim):
	if anim == "Hello" and not helloed:
		helloed = true
	elif anim == "Hello":
		$sprite/anim_player.play("Idle")
		helloed = false

func _input(event):
	var talk_direction = $"../../rex".talk_direction()
	var rex_distance = $"../../rex".position - position
	var rex_direction = rex_distance.normalized()

	if Input.is_action_just_pressed("ui_up") and can_talk and not talking and talk_direction.dot(rex_direction) <-0.5:
		
		$sprite/sprite.flip_h = rex_distance.x < 0
		$sprite/anim_player.play("Hello")

		
		$message_box.show_text(dialogue[current_text])
		
		if current_text + 1 < dialogue.size():
			current_text += 1

		talking = true

		$"../../rex".talking($message_box.global_position)


func on_finished_message():
	$sprite/anim_player.play_backwards("Hello")
	$message_box.close()
	$timer.start()

func on_can_talk_again():
	talking = false
	$"../../rex".no_talking()
