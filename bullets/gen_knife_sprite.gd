extends Node

func _ready():
	$anim_player.play("Roll")


func flip(left=true):
	$sprite.flip_h = left
