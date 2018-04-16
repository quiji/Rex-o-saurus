extends KinematicBody2D


var Bricks = preload("res://sparks/bricks.tscn")
var SoldierA = preload("res://enemies/soldier_a.tscn")
var SoldierB = preload("res://enemies/soldier_b.tscn")
var Carrot = preload("res://item/carrot.tscn")

export (int) var knife_soldiers = 100
export (int) var rifle_soldiers = 50
export (int) var machine_gun_soldiers = 50
export (int) var max_health = 1500


const MAX_TIMER = 5.0
var total_soldiers = 100
var health = 0.0
var wait_time = 0.0
var penalty = 0.0
var castle_start_pos 

var castle_front

var delta_count = 0
var burst = 0
var burst_delta = 0
const BURST_TIME = 0.3

func _ready():
	
	var pos = $sprite/front_castle.global_position
	var front_castle = $sprite/front_castle
	$sprite.remove_child(front_castle)
	$"../../front_houses".add_child(front_castle)
	castle_front = front_castle
	front_castle.global_position = pos
	castle_start_pos = $sprite/castle.position
	
	health = max_health

	wait_time = MAX_TIMER
	total_soldiers = knife_soldiers + rifle_soldiers + machine_gun_soldiers
	delta_count = MAX_TIMER



func _physics_process(delta):
	var rex_distance = $"../../rex".position - position

	
	if rex_distance.length_squared() < 300 * 300:
		delta_count += delta
		if delta_count >= wait_time:
			delta_count = 0
			burst = 5
	else:
		delta_count = MAX_TIMER

	if burst > 0:
		if burst_delta < BURST_TIME:
			burst_delta += delta
		else:
			on_timeout()
			burst_delta = 0
			burst -= 1
	

func on_timeout():

	var rex_distance = $"../../rex".position - position
	var soldier = 0
	if knife_soldiers > 0:
		knife_soldiers -= 1
		soldier = 0
	elif rifle_soldiers > 0:
		rifle_soldiers -= 1
		soldier = 1
	elif machine_gun_soldiers > 0:
		machine_gun_soldiers -= 1
		soldier = 2
		
	if rex_distance.normalized().dot(Vector2(1, 0)) < 0:
		$factory.spawn(soldier, $left_spawn.position + position, -1)
	else:
		$factory.spawn(soldier, $right_spawn.position + position, 1)
	
	total_soldiers = knife_soldiers + rifle_soldiers + machine_gun_soldiers
	
	if total_soldiers <= 0:
		set_physics_process(false)
		$whiteflag.show()
		$whiteflag/anim_player.play("Flag")
		
	

func add_soldier(weapon):

	if total_soldiers <= 0:
		return false
	else:
		damage_structure(-20)
		total_soldiers += 1
		if weapon == 0:
			knife_soldiers += 1
		elif weapon == 1:
			rifle_soldiers += 1
		elif weapon ==2:
			machine_gun_soldiers += 1
		return true



func bulleted(damage, poss=[]):
	emit_bricks(poss, 0)
	return damage_structure(damage)

func whipped(direction, poss=[]):
	$whip_crumble.play()
	emit_bricks(poss, 2)
	#var rex_distance_left = ($"../../rex".global_position - $emitter/left_brick_top0.global_position).length()
	#var rex_distance_right = ($"../../rex".global_position - $emitter/right_brick_top0.global_position).length()
	
	$tween.interpolate_method(self, "shrink_horizontal", 0.95, 1, 0.2,Tween.TRANS_BOUNCE, Tween.EASE_IN)
	$tween.start()

	return damage_structure(50)
	
func stomped(strength=0, poss=[]):
	$stomp_crumble.play()
	emit_bricks(poss, strength)
	$tween.interpolate_method(self, "shrink_vertical", 0.95, 1, 0.2,Tween.TRANS_BOUNCE, Tween.EASE_IN)
	$tween.start()

	return damage_structure(30 * (strength + 1))

func damage_structure(damage):
	health -= damage

	wait_time = MAX_TIMER * Smoothstep.start2(health / max_health) + penalty
	
	if health <= 0:
		set_physics_process(false)
		total_soldiers = 0
		
		$crumble.play()
		$crumble_anim.play("Crumble")

		get_tree().call_group("soldiers", "castle_destroyed")
		return true
	return false
	
func crumble_dust():
	$sprite/brick_dust_left.emitting = true
	$sprite/brick_dust_right.emitting = true
	collision_layer = 0

func remove_collision():
	collision_layer = 0

func animate_fall():
	$sprite/back_castle/anim_player.play("Crumble")
	$sprite/castle/anim_player.play("Crumble")
	castle_front.get_node("anim_player").play("Crumble")

	var carrot = Carrot.instance()
	carrot.position = position + Vector2(40, -5)
	$"../../front_row".add_child(carrot)

	
func shrink_vertical(t):
	$sprite/castle.scale.y = t
	$sprite/castle.position.y = castle_start_pos.y + (1 - t) + 0.1

func shrink_horizontal(t):
	$sprite/castle.scale.x = t
	

func emit_bricks(poss, strength):
	var i = 0
	
	while i < poss.size():
		var brick = Bricks.instance()
		add_child(brick)
		brick.global_position = poss[i]
		brick.start(strength)
		i += 1
