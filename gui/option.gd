extends Label

export (int, "continue", "exit") var action

func active():
	$tween.interpolate_property(self, "modulate", Color("#a8b39e"), Color("#ba3e1c"), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$tween.start()

func inactive():
	$tween.interpolate_property(self, "modulate", Color("#ba3e1c"), Color("#a8b39e"), 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$tween.start()

