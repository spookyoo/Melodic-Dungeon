extends Control

# Called when the node enters the scene tree for the first time.

func _ready():
	$FloorLabel.text = "Floor " + str(GlobalPlayer.floor)
