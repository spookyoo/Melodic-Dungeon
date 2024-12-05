extends Node

const INSTRUMENT_PATH = "res://player/assets/"

var instruments = {
	"lute": {
		"icon": INSTRUMENT_PATH + "lute.png",
		"comboThreshold": 8,
		"passive": 0, #RANGE INCREASE
		"active": "Resonating Tune",
		"description": "A lute with a powerful tune",
	},
	
	"drum": {
		"icon": INSTRUMENT_PATH + "drum.png",
		"comboThreshold": 10,
		"passive": 1.5, #SPEED BOOST
		"active": "Rapid Rhythm",
		"description": "The drum's rhythm makes you quicker on your feet",
	},
	
	"recorder": {
		"icon": INSTRUMENT_PATH + "recorder.png",
		"comboThreshold": 14,
		"passive":  25,#INCREASED MAX HP
		"active": "Soothing Grace", 
		"description": "The recorder plays a soothing melody",
	},
}
