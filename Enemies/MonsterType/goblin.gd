extends Enemy
class_name Goblin

# Goblins have low HP but are super fast
func _ready():
	minHealth = 2
	maxHealth = 6
	speed = 15
	super._ready()
	
	#print("Goblin keys: " + keys)