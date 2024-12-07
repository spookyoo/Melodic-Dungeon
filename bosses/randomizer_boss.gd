extends Enemy
class_name Boss

var health
signal bossDefeated

@export var randomizeTimer: Timer

var isVulnerable: bool = true
var isRandomizing: bool = false

func _ready():
	minHealth = 1 #UNUSED BUT STOPS CRASHING
	maxHealth = 30
	
	health = clamp(10 + (GlobalPlayer.floor * 3), 10, maxHealth) #DEFAULT 2
	
	super()
	keys = genRandomkeys(health)
	keyQueue = keys.split(" ")
	label.text = str(keys)     # ensures the intial keystrokes are displayed
	randomizeTimer.start()

func damageBoss():
	if not isVulnerable:
		return
	health -= 1
	currentKeyIdx += 1
		
	if health <= 0:
		die()

func die():
	bossDefeated.emit()
	call_deferred("queue_free")

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
