extends Node

const INSTRUMENT_PATH = "res://player/assets/"

func _ready():
	pass

var instruments = {
	"lute": {
		"icon": INSTRUMENT_PATH + "lute.png",
		"comboThreshold": 8, #8
		"passive": 1, #RANGE INCREASE
		"active": "Resonating Tune - Double Note",
		"description": "A lute with a powerful tune",
	},
	
	"drum": {
		"icon": INSTRUMENT_PATH + "drum.png",
		"comboThreshold": 10,
		"passive": 1, #SPEED BOOST
		"active": "Rapid Rhythm - Speed Boost",
		"description": "The drum's rhythm makes you quicker on your feet",
	},
	
	"recorder": {
		"icon": INSTRUMENT_PATH + "recorder.png",
		"comboThreshold": 14,
		"passive":  15,#INCREASED MAX HP
		"active": "Soothing Grace - Heal", 
		"description": "The recorder plays a soothing melody",
	},
}

var instrumentSounds = {
	"drum": genSoundPath("drum"),
	"lute": genSoundPath("lute"),
	"recorder": genSoundPath("recorder"),
	}

func genSoundPath(instrumentName: String) -> Array:
	var basePath = "res://player//sounds/correct/%s/" % instrumentName
	var sounds = []
	
	for i in range(1, 9):
		sounds.append("%ssound%d.wav" % [basePath, i])
	
	# Add the incorrect sound
	sounds.append("%sincorrect_%s.wav" % [basePath, instrumentName])
	return sounds
