extends Enemy
class_name Ogre

# Ogres have High HP but are super slow
func _ready():
	minHealthCap = 6
	maxHealthCap = 8
	minHealth = clamp(3 + (GlobalPlayer.floor - 1), 0, minHealthCap) #DEFAULT 3
	maxHealth = clamp(5 + (GlobalPlayer.floor - 1), 0, maxHealthCap) #DEFAULT 5
	
	speed = 12
	damage = 10
	super._ready()
	
	#print("Ogre keys: " + keys)
