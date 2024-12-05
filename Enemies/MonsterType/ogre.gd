extends Enemy
class_name Ogre

# Ogres have High HP but are super slow
func _ready():
	minHealth = 6
	maxHealth = 10
	speed = 12
	damage = 10
	super._ready()
	
	#print("Ogre keys: " + keys)
