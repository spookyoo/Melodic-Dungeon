extends CharacterBody3D
class_name Enemy

var health = 100
@onready var label = $Label
@export var attackDistance = 10.0
@export var speed = 10
@onready var attackQueue = get_tree().get_current_scene().get_node("AttackQueue") 

var keys: String = ""
var keyQueue: Array = []
var currentKeyIdx = 0
var isAttacking = false
var player
var counter = 0

func _ready():
	player = get_tree().get_current_scene().get_node("Player")
	
	keys = genRandomkeys(int(randf_range(1,5)))
	keyQueue = keys.split(" ")
	label.text = str(keys)

func _physics_process(delta):
	counter += 1
	if counter % 5 == 0:
		if isAttacking:
			moveTowardsPlayer(delta)
		else:
			checkProximity()
	

func genRandomkeys(numKeys: int) -> String:
	var keys = ["Z", "X", "C", "V", "Q",]
	var randomKeys = []
	
	for i in range(numKeys):
		var randomIdx = randi() % keys.size()
		randomKeys.append(keys[randomIdx])
		
	return " ".join(randomKeys)
	
func updateLabel():
	label.text = " ".join(keyQueue)
	#label.text = " ".join(keyQueue)
	var completedKeys = keyQueue.slice(0, currentKeyIdx)
	var remainingKeys = keyQueue.slice(currentKeyIdx, keyQueue.size())
	
# Attack Related Stuff
func checkProximity():
	if not isAttacking and (global_transform.origin - player.global_transform.origin).length() <= attackDistance:
		if attackQueue.reqAttack(self):
			startAttack()

func startAttack():
	isAttacking = true
	# we could play animations here later

func finishAttack():
	isAttacking = false
	attackQueue.finishAttack(self)
	
func moveTowardsPlayer(delta):
	var direction = (player.global_transform.origin - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()
	
	if (global_transform.origin - player.global_transform.origin).length() > attackDistance:
		finishAttack()
	
