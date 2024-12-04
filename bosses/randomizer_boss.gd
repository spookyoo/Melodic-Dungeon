extends Enemy
class_name Boss

var maxHealth = 35

func _ready():
	super()
	health = maxHealth
	keys = genRandomkeys(maxHealth)
	keyQueue = keys.split(" ")
	label.text = str(keys)     # ensures the intial keystrokes are displayed
	
func takeDamage():
	health -= 1
	currentKeyIdx += 1
	
	if health == maxHealth * 2/3:
		print("Phase 2: Randomizing Keystrokes")
		keys = genRandomkeys(int(maxHealth * 2/3))
		keyQueue = keys.split(" ")
		currentKeyIdx = 0
		label.text = str(keys)
		
	elif health == maxHealth * 1/3:
		print("Phase 3: Randomizing Keystrokes")
		keys = genRandomkeys(int(maxHealth * 1/3))
		keyQueue = keys.split(" ")
		currentKeyIdx = 0
		label.text = str(keys)
		
	if health <= 0:
		defeat()
		
func defeat():
	print("Boss defeated!")
	queue_free()
