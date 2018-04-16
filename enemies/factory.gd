extends Node2D

var SoldierA = preload("res://enemies/soldier_a.tscn")
var SoldierB = preload("res://enemies/soldier_b.tscn")
var SoldierC = preload("res://enemies/soldier_c.tscn")

const DISTANCE_PER_SOLDIER = 32

enum SOLDIER_FORMATION  {LINE}
enum SOLDIER_ROWS {BACK, BACK_MIDDLE, MIDDLE, FRONT_MIDDLE, FRONT}
enum SOLDIER_SPAWN_MODE {INSTANT, ON_CUE}

export (int) var knife_soldiers = 0
export (int) var rifle_soldiers = 0
export (int) var machine_gun_soldiers = 0
export (int, "LINE") var formation

export(int, "INSTANT", "ON_CUE", "MANUAL") var spawn_mode

func _ready():
	
	$sprite.queue_free()
	if spawn_mode == INSTANT:
		if formation == LINE:
			line_formation()

var current_row = 0
func spawn(soldier_type, spawn_pos, direction):
	var soldier
	var parent
	
	match current_row:
		BACK:
			parent = $"../../../back_row"

		BACK_MIDDLE:
			parent = $"../../../back_middle_row"

		MIDDLE:
			parent = $"../../../middle_row"

		FRONT_MIDDLE:
			parent = $"../../../front_middle_row"

		FRONT:
			parent = $"../../../front_row"
		_:
			parent = $"../../../middle_row"

	
	if soldier_type == 0:
		soldier = SoldierA.instance()
		soldier.weapon = soldier.WEAPON_TYPES.KNIFE
	elif  soldier_type == 1:
		soldier = SoldierB.instance()
		soldier.weapon = soldier.WEAPON_TYPES.RIFLE
	elif  soldier_type == 2:
		soldier = SoldierC.instance()
		soldier.weapon = soldier.WEAPON_TYPES.MACHINE_GUN

	soldier.people_row = MIDDLE
	soldier.position = spawn_pos
	parent.add_child(soldier)
	soldier.run_to_row(current_row, direction)


	if current_row < FRONT:
		current_row += 1
	else:
		current_row = 0



func line_formation():
	var i = 0
	var row_count = 0
	while knife_soldiers + rifle_soldiers + machine_gun_soldiers > 0:

		var parent
		var soldier

		match i:
			BACK:
				parent = $"../../back_row"

			BACK_MIDDLE:
				parent = $"../../back_middle_row"

			MIDDLE:
				parent = $"../../middle_row"

			FRONT_MIDDLE:
				parent = $"../../front_middle_row"

			FRONT:
				parent = $"../../front_row"
			_:
				parent = $"../../middle_row"

		if knife_soldiers > 0:
			soldier = SoldierA.instance()
			knife_soldiers -= 1
			soldier.weapon = soldier.WEAPON_TYPES.KNIFE
		elif rifle_soldiers > 0:
			soldier = SoldierB.instance()
			rifle_soldiers -= 1
			soldier.weapon = soldier.WEAPON_TYPES.RIFLE
		elif machine_gun_soldiers > 0:
			soldier = SoldierC.instance()
			machine_gun_soldiers -= 1
			soldier.weapon = soldier.WEAPON_TYPES.MACHINE_GUN

		soldier.people_row = i
		soldier.position = position + Vector2(row_count * DISTANCE_PER_SOLDIER, 0)
		parent.add_child(soldier)

		if i < FRONT:
			i += 1
		else:
			i = 0
			row_count += 1


