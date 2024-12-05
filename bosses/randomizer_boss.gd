extends Enemy
class_name Boss

var maxHealth = 35
@export var randomizeTimer: Timer

var isVulnerable: bool = true
var isRandomizing: bool = false

func _ready():
	super()
	health = maxHealth
	keys = genRandomkeys(maxHealth)
	keyQueue = keys.split(" ")
	label.text = str(keys)     # ensures the intial keystrokes are displayed
	randomizeTimer.start()

func takeDamage():
	if not isVulnerable:
		return
	health -= 1
	currentKeyIdx += 1
		
	if health <= 0:
		defeat()
		
func defeat():
	print("Boss defeated!")
	queue_free()


func _on_randomize_timer_timeout() -> void:
	isVulnerable = false
	isRandomizing = true
	
	label.text = "? ".repeat(health)
	await get_tree().create_timer(1).timeout
	
	# Change the keys
	keys = genRandomkeys(health)
	keyQueue = keys.split(" ")
	label.text = str(keys)
	
	# End randomziing
	isRandomizing = false
	isVulnerable = true
