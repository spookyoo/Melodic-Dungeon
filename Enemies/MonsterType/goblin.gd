extends Enemy
class_name Goblin

# Goblins have low HP but are super fast
func _ready():
	minHealth = 1 #DEFAULT 1
	maxHealth = 2 #DEFAULT 2
	minHealthCap = 4
	maxHealthCap = 5
	
	speed = 18
	damage = 6
	super._ready()
	
	#print("Goblin keys: " + keys)
