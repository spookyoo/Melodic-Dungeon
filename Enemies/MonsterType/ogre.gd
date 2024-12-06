extends Enemy
class_name Ogre

# Ogres have High HP but are super slow
func _ready():
	minHealth = 3 #DEFAULT 3
	maxHealth = 5 #DEFAULT 5
	
	minHealthCap = 6
	maxHealthCap = 8
	speed = 12
	damage = 10
	super._ready()
	
	#print("Ogre keys: " + keys)
