extends Control

@onready var player = get_tree().get_current_scene().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.comboUpdate.connect(self.update)
	instantiate()
	pass

func instantiate():
	$ComboLabel.text = "Melodic Infusion x0"
	
func update(currentCombo):
	$ComboLabel.text = "Melodic Infusion x" + str(currentCombo)
	
	### add a message when hitting perfect combo
	#if player.perfectComboActive:
		#$ComboLabel.text += " x Combo Activated"
