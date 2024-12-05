extends Enemy
class_name Ogre

# Ogres have High HP but are super slow
func _ready():
	health = 12
	speed = 8
	super._ready()
	
	#print("Ogre keys: " + keys)
