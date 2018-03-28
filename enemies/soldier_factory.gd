extends KinematicBody2D

var SoldierA = preload("res://enemies/soldier_a.tscn")

const MAX_HEALTH = 3000.0
const MAX_TIMER = 5.0
var total_soldiers = 200
var health = 0.0
var wait_time = 0.0
var penalty = 0.0
var castle_start_pos 

func _ready():
	
	var pos = $sprite/front_castle.global_position
	var front_castle = $sprite/front_castle
	$sprite.remove_child(front_castle)
	$"../../first_foreground".add_child(front_castle)
	front_castle.global_position = pos
	castle_start_pos = $sprite/castle.position
	
	health = MAX_HEALTH

	wait_time = MAX_TIMER
	

var delta_count = 0

func _physics_process(delta):
	delta_count += delta
	if delta_count >= wait_time:
		delta_count = 0
		on_timeout()


func on_timeout():
	var i = 4
	var j = 2
	while i > 0 and total_soldiers > 0:
		var soldier = SoldierA.instance()
		
		var rex_distance = $"../../rex".position - position
		var rex_direction = rex_distance.normalized()

		if j > 0:
			if Vector2(-1, 0).dot(rex_direction) >= 0:
				soldier.position = position + $right_top_spawn.position
				soldier.ai_transit_to(soldier.IDLE)
			else:
				soldier.position = position + $left_top_spawn.position
				soldier.ai_transit_to(soldier.IDLE)
		else:
			if Vector2(-1, 0).dot(rex_direction) >= 0:
				soldier.position = position + $left_spawn.position
				soldier.ai_transit_to(soldier.OUT_LEFT, true)
			else:
				soldier.position = position + $right_spawn.position
				soldier.ai_transit_to(soldier.OUT_RIGHT, true)
				
		$"../../enemies".add_child(soldier)
		if j == 0:
			i -= 1
		else:
			j -= 1
		total_soldiers -= 1

	if total_soldiers <= 0:
		set_physics_process(false)
		$whiteflag.show()
		$whiteflag/anim_player.play("Flag")
		
	

func add_soldier():
	if total_soldiers <= 0:
		return false
	else:
		damage_structure(-20)
		total_soldiers += 1
		return true


func whipped(direction):
	var rex_distance_left = ($"../../rex".global_position - $emitter/left_brick_top0.global_position).length()
	var rex_distance_right = ($"../../rex".global_position - $emitter/right_brick_top0.global_position).length()
	
	if rex_distance_left < rex_distance_right:
		emit_bricks("left_brick_top")
	else:
		emit_bricks("right_brick_top")
	$tween.interpolate_method(self, "shrink_horizontal", 0.95, 1, 0.2,Tween.TRANS_BOUNCE, Tween.EASE_IN)
	$tween.start()

	damage_structure(50)
	
func stomped(strength=0):
	emit_bricks("left_brick_top")
	emit_bricks("right_brick_top")
	$tween.interpolate_method(self, "shrink_vertical", 0.95, 1, 0.2,Tween.TRANS_BOUNCE, Tween.EASE_IN)
	$tween.start()

	damage_structure(30 * (strength + 1))

func damage_structure(damage):
	health -= damage

	wait_time = MAX_TIMER * Smoothstep.start2(health / MAX_HEALTH) + penalty

	
	if health <= 0:
		emit_all_bricks()
		set_physics_process(false)
		total_soldiers = 0
		$sprite/castle.hide()
		$whiteflag.hide()
		collision_layer = 0
		$sprite/falling_tower.play("Fall")
		get_tree().call_group("soldiers", "castle_destroyed")
	
	
func shrink_vertical(t):
	$sprite/castle.scale.y = t
	$sprite/castle.position.y = castle_start_pos.y + (1 - t) + 0.1

func shrink_horizontal(t):
	$sprite/castle.scale.x = t
	

func emit_bricks(who):
	var i = randi() % 10
	var bricks = get_node("emitter/" + who + str(i))
	if not bricks.emitting:
		bricks.emitting = true
	else:
		bricks.restart()

func emit_all_bricks():
	$emitter/left_brick_top0.emitting = true
	$emitter/right_brick_top0.emitting = true
	$emitter/left_brick_top1.emitting = true
	$emitter/right_brick_top1.emitting = true
	$emitter/left_brick_top2.emitting = true
	$emitter/right_brick_top2.emitting = true
	$emitter/left_brick_top3.emitting = true
	$emitter/right_brick_top3.emitting = true
	$emitter/left_brick_top4.emitting = true
	$emitter/right_brick_top4.emitting = true
	$emitter/left_brick_top5.emitting = true
	$emitter/right_brick_top5.emitting = true
	$emitter/left_brick_top6.emitting = true
	$emitter/right_brick_top6.emitting = true
	$emitter/left_brick_top7.emitting = true
	$emitter/right_brick_top7.emitting = true
	$emitter/left_brick_top8.emitting = true
	$emitter/right_brick_top8.emitting = true
	$emitter/left_brick_top9.emitting = true
	$emitter/right_brick_top9.emitting = true

