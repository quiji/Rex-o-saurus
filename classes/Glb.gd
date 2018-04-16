extends Node


func _ready():
	randomize()


var checkpoint = Vector2()
func get_checkpoint():
	return checkpoint

func set_checkpoint(chk):
	checkpoint = chk

var dialogues = [
	# Rosita
	[
		[
			# Option 1
			[
				"Hello there Sir! Are you looking for some potions?",
				"I'm the shopkeeper, Rosita. I don't have stock now...",
				"But once you face some challenges in this story, I'm probably going to have some good stuff... I hope...",
				"Probably in the version 2.0 of this game."
			],
			[
				"Bussiness have been too slow, you know... because of the monsters down the mountain."
			]
		]
	],
	
	# Jack
	[
		[
			# Option 1
			[
				"Hello Stranger! I'm Jack! The only blacksmith in town! Do you need some weapons?",
				"If you do I'll gladly make a powerful, modern, responsive, flexible, ergonomic, fast, and beautiful weapon!!",
				" Although with those arms... I'm afraid you won't be able to use a sword, you are probably better with techniques like 'Quick Attack', 'Hyper Beam' or 'Water Pump'"
			],
			[
				"Hyper Beam? You need a TM and a Dragon type... Where? ",
				"I'm afraid not here, man. This is a low budget creation.  Here you can only use your trusty old tail."
			],
			[
				"Whip them hard!"
			]
		]
	],
	
	# Female NPC
	[
		[
			# Option 1
			[
				"Hi! Are you looking for some insight into how to use your abilities?",
				"You are in luck! I know everything! Use the directional buttons to move.",
				"The 'Z' key will allow you to jump and the 'X' key will release a powerful 'Tail Whip'.",
				"No, not the kind of Tail Whip that lowers your defense, the kind that sends stuff flying in the air."
			],
			[
				"There are some strange green fellows don't the mountain who have tremendous amount of power, because of some stolen cristal or something.",
				"Proceed with caution!"
			],
			[
				"You are big, scary and sexy. Did you know you can roar?",
				"Press the 'A' button and scare the hell out of them!"
			]
		]
	],
	
	# Male NPC
	[
		[
			# Option 1
			[
				"Hey...",
				"I'm bored.",
				"I'm supposed to say something about some ring, and give you a very interesting lore talk... But I forgot my lines"
			],
			[
				"This is a low budget game, man. They are paying me a nickel to be a random NPC so I'm not trying hard to remember the lines."
			],
			[
				"Down the mountain you'll face some enemies.",
				"Don't worry, I think you are up to the task",
				"They are green and dumb. Remember that."
			]
		]
	],
	
	# Rat King
	[
		[
			# Option 1
			[
				"Behold the Rat King!! Kneel!"
			],
			[
				"Who am I? The RAT KING!!"
			],
			[
				"Well, they couldn't hire the Toad King, so here I'm. I was supposed to be a powerful, yet funny boss...",
				"But there were some problems with development deadlines and I got moved to NPC status... what a boomer.",
				"NPC Status?? Non Playable Character! It's boring, you say the same lines over and over again!"
			]
		]
	],
	
	# Final NPC
	[
		[
			# Option 1
			[
				"I'm afraid the game ends here.",
				"There was a lot of content planned: bosses, weapons, lore... but time ran off.",
				"As a matter of fact... this level is incomplete. From here on, you fall into infinity. ",
				"I guess you'll have to make the jump of faith"
			],
			[
				"Did you notice that you cannot die? ",
				"It's because of the very interesting and unique 'Death mechanic'.",
				"Bascially you cannot die.",
				"The energy bar? It's for fun!"
			]
		]
	]
]

func get_dialogue(character):
	var options = dialogues[character].size()
	var picked = randi() % options
	return dialogues[character][picked]

