extends Node

var instrument = ""
var rarity = ""
var player : CharacterBody3D = null
signal update

var score
var floor = 1
var time = 0.0

func _ready():
	return

func instantiate():
	if instrument == "":
		changeInstrument(GlobalInstruments.instruments.keys().pick_random(),"common")
	notifyUpdate()

func changeInstrument(newInstrument, newRarity):
	instrument  = newInstrument
	rarity = newRarity
	notifyUpdate()

func notifyUpdate():
	update.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
