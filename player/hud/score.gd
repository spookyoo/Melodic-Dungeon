extends Control

@onready var player = get_tree().get_current_scene().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.scoreUpdate.connect(self.update)
	instantiate()
	update(GlobalPlayer.score)
	pass

func instantiate():
	$ScoreLabel.text = "00000000"
	
func update(currentScore):
	$ScoreLabel.text = "%08d" % currentScore
	
	### add a message when hitting perfect combo
	#if player.perfectComboActive:
		#$ComboLabel.text += " x Combo Activated"
