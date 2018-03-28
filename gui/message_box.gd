extends Node2D

const BOX_SIZE = 5.0
const FONT_SIZE = 7
const BOX_PER_CHAR = 1.85
const CHARS_PER_LINE = 20

signal finished_message

func _ready():
	modulate = Color("00ffffff")
	$text.show()
	structure_box(Vector2(10, 10))
	
func structure_box(box_size, show_arrow=false):
	box_size += Vector2(4, 4)
	$movables/up_left.position = Vector2(-BOX_SIZE, BOX_SIZE * -(box_size.y + 1))
	$movables/up_right.position = Vector2(BOX_SIZE * (box_size.x + 1), BOX_SIZE * -(box_size.y + 1))
	$movables/bottom_right.position = Vector2(BOX_SIZE * (box_size.x + 1), -BOX_SIZE)

	$strechables/up.position= Vector2(0, BOX_SIZE * -(box_size.y + 1))
	$strechables/up.scale.x = box_size.x + 1

	$strechables/left.position= Vector2(-BOX_SIZE, -BOX_SIZE * (box_size.y))
	$strechables/left.scale.y = box_size.y - 1

	$strechables/bottom.position = Vector2(BOX_SIZE, -BOX_SIZE)
	$strechables/bottom.scale.x = box_size.x

	$strechables/right.position= Vector2(BOX_SIZE * (box_size.x + 1), -BOX_SIZE * (box_size.y))
	$strechables/right.scale.y = box_size.y - 1

	$strechables/in.position = Vector2(0, -BOX_SIZE * (box_size.y))
	$strechables/in.scale = Vector2(box_size.x + 1, box_size.y - 1)

	$text.position = Vector2(BOX_SIZE, BOX_SIZE * -(box_size.y - 0.5))

	if show_arrow:
		$movables/arrow.position = Vector2(BOX_SIZE * (box_size.x + 1) - 10, -BOX_SIZE - 6)
		$movables/arrow.show()

func show_message(msg):
	$text/message.text = msg
	var size = Vector2( BOX_PER_CHAR * CHARS_PER_LINE, $text/message.get_line_count() * $text/message.get_line_height() / BOX_SIZE)

	if msg.length() < 20:
		size.x = BOX_PER_CHAR * msg.length()
	structure_box(size, true)

func close():
	$tween.interpolate_property(self, "modulate", modulate, Color("00ffffff"), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$tween.start()
	$movables/arrow.hide()
	messages = null

var current_message = 0
var messages = null
func show_text(msgs):
	current_message = 0
	messages = msgs
	show_message(msgs[current_message])
	$tween.interpolate_property(self, "modulate", modulate, Color("ffffffff"), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$tween.start()

func _input(event):
	if messages == null:
		return
		
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		if current_message + 1 < messages.size():
			current_message += 1
			show_message(messages[current_message])
		else:
			emit_signal("finished_message")
			