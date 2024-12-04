extends Node

const INSTRUMENT_PATH = "res://player/assets/"

var instruments = {
	"lute": {
		"icon": INSTRUMENT_PATH + "lute.png",
		"comboThreshold": 8,
		"passive": 0, #NONE
		"active": "none",
		"description": "Its an ordinary old lute with a powerful sound.",
	},
	
	"drum": {
		"icon": INSTRUMENT_PATH + "drum.png",
		"comboThreshold": 10,
		"passive": 1.5, #SPEED BOOST
		"active": "Burst of speed",
		"description": "The drum's rhythm makes you quicker on your feet.",
	},
	
	"recorder": {
		"icon": INSTRUMENT_PATH + "recorder.png",
		"comboThreshold": 16,
		"passive":  25,#INCREASED MAX HP
		"active": "Heal",
		"description": "The recorder plays a soothing sound.",
	},
}
