extends Node

func _ready():
	$anim_player.play("Roll")
	$anim_player.connect("animation_finished", self, "on_animation_finished")



func flip(left=true):
	$sprite.flip_h = left

func dismiss():
	$anim_player.play("Dismiss")

func on_animation_finished(anim):
	get_parent().queue_free()
	
