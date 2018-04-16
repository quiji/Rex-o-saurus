extends Node2D


var fading_out_from_death = false

var own_modulate = null
var gui_modulate = null
var background_modulate = null
var tween = null

func _ready():
	
	tween = Tween.new()
	add_child(tween)
	
	own_modulate = CanvasModulate.new()
	own_modulate.color = Color(0, 0, 0)
	add_child(own_modulate)
	
	gui_modulate = $gui/modulate
	gui_modulate.color = Color(0, 0, 0)
	
	if has_node("background"):
		background_modulate = CanvasModulate.new()
		background_modulate.color = Color(0, 0, 0)
		$background.add_child(background_modulate)

	fade_in()

	Glb.set_checkpoint($rex.position)

	tween.connect("tween_completed", self, "on_tween_completed")


func fade_in():
	tween.interpolate_property(own_modulate, "color", own_modulate.color, Color(1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property(gui_modulate, "color", gui_modulate.color, Color(1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property(background_modulate, "color", background_modulate.color, Color(1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()


func fade_out(death=false):
	if death:
		tween.interpolate_property(own_modulate, "color", own_modulate.color, Color(1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(gui_modulate, "color", gui_modulate.color, Color(1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(background_modulate, "color", background_modulate.color, Color(1, 1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		fading_out_from_death = true
	else:
		tween.interpolate_property(own_modulate, "color", own_modulate.color, Color(0.5, 0.5, 0.5), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(gui_modulate, "color", gui_modulate.color, Color(0.5, 0.5, 0.5), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.interpolate_property(background_modulate, "color", background_modulate.color, Color(0.5, 0.5, 0.5), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()

func on_tween_completed(obj, prop):
	if fading_out_from_death:
		fading_out_from_death = false
		get_tree().reload_current_scene()
		#$rex.position = Glb.get_checkpoint()
		#$rex.rebirth()
		#fade_in()

func spawn_in_checkpoint(pos):
	fade_out(true)



func _on_end_body_entered(body):
	fade_out(true)



