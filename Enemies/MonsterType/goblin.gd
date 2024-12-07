extends Enemy
class_name Goblin

# Goblins have low HP but are super fast
func _ready():
	minHealthCap = 4
	maxHealthCap = 5
	minHealth = clamp(1 + (GlobalPlayer.floor - 1), 0, minHealthCap) #DEFAULT 1
	maxHealth = clamp(2 + (GlobalPlayer.floor - 1), 0, maxHealthCap) #DEFAULT 2
	
	speed = 18
	damage = 6
	super._ready()
	
	#print("Goblin keys: " + keys)
