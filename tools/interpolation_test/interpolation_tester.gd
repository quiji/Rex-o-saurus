
extends Node2D
var Smooth = preload("res://classes/Smoothstep.gd")



func _ready():
	
	$interpolator.set_method(self, "inter")
	$interpolator2.set_method(self, "inter2")
	$interpolator3.set_method(self, "inter3")
	$interpolator4.set_method(self, "inter4")
	$interpolator5.set_method(self, "inter5")



func inter(t):
	return Smoothstep.arch(t, 4)

func inter2(t):
	return Smoothstep.flip(Smoothstep.stop4(t))


func inter3(t):
	return Smoothstep.start2(t)

func inter4(t):
	return Smoothstep.start2(t)

func inter5(t):
	return Smoothstep.cross(t, Smoothstep.arch(Smoothstep.stop6(t), 2), Smoothstep.flip(Smoothstep.arch(Smoothstep.start6(t), 0.5)))


