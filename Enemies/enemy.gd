extends CharacterBody3D
class_name Enemy

var health = 5
@onready var label = $Label
@export var attackDistance = 20.0
@export var speed = 15
@onready var attackQueue = get_tree().get_current_scene().get_node("AttackQueue") 

var keys: String = ""
var keyQueue: Array = []
var currentKeyIdx = 0
var isAttacking = false
var player
var counter = 0
var isFreed = false    # flag to check if enemy has been freed

func _ready():
	player = get_tree().get_current_scene().get_node("Player")
	#keys = genRandomkeys(int(randf_range(1,5)))
	keys = genRandomkeys(int(randf_range(1,health)))
	keyQueue = keys.split(" ")
	label.text = str(keys)

func _physics_process(delta):
	if isFreed:
		return         # STOP ANYTHING THAT IS HAPPENING if enemy is freed
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
	if isFreed or not is_instance_valid(player):
		return
	
	# distance to player
	var distance = (global_transform.origin - player.global_transform.origin).length()
	if not isAttacking and distance <= attackDistance:
		if attackQueue.reqAttack(self):
			startAttack()

func startAttack():
	if isFreed:
		return
	isAttacking = true
	# we could play animations here later

func finishAttack():
	if isFreed:
		return
	isAttacking = false
	if is_instance_valid(attackQueue):
		attackQueue.finishAttack(self)
	
func moveTowardsPlayer(delta):
	if isFreed or not is_instance_valid(player):
		return
	var direction = (player.global_transform.origin - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()
	
	if (global_transform.origin - player.global_transform.origin).length() > attackDistance:
		finishAttack()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(attackQueue):
			attackQueue.finishAttack(self)
func die():
	call_deferred("queue_free")
