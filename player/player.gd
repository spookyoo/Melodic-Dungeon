extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
var lastCollided : Enemy = null
var playerHealth = 100
var currentKeyIdx = 0


const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

# Bob variables
const BOB_FREQ = 2.0
const BOB_AMP= 0.08

# FOV Variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel") || event.is_action_pressed("exit"):
		get_tree().quit()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		handleCamera(event)

func _physics_process(delta: float) -> void:	
	handleJumping(delta)
	applyMovement(delta)
	applyCamEffects(delta)
	move_and_slide()
	performRaycast()
	handleInput()


func handleCamera(event):
	"""
	Handles camera rotation based on mouse movement
	
	Rotates player's head horizontally and the camera vertically based on the mouse's relative movement
	
	Args:
		event (InputEventMouseMotion): Event containing mouse motion data
	"""
	if event is InputEventMouse:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -40, 60)

func handleJumping(delta):
	"""
	Applies gravity and handles jump input
	
	If player is grounded and presses jump they will jump, otherwise gravity is applied to pull down
	
	Args:
		delta (float): Time elapsed since last frame (seconds)
	"""
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func applyMovement(delta):
	"""
	Calculate and apply player movement based on input and sprinting

	Determines direction based on input (WASD keys), then adjusts velocity for walking/sprinting
	Also interpolates movement when player is airborne

	Args:
		delta (float): Time elapsed since last frame (seconds)
	"""
	var speed = WALK_SPEED
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		velocity.x = direction.x * speed if direction else 0.0
		velocity.z = direction.z * speed if direction else 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

func applyCamEffects(delta):
	"""
	Applies cam effects such as head bobbing and field of view (FOV)
	
	Function calculates and applies head bobbing effect based on movement speed then adjusts FOV dynamically depending on player velocity
	
	Args:
		delta (float): Time elapsed since last frame (seconds)
	"""
	# Head Bob
	var t_bob = 0.0
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = calcHeadbob(t_bob)
	
	# FOV:
	var velocityClamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var targetFOV = BASE_FOV + FOV_CHANGE * velocityClamped
	camera.fov = lerp(camera.fov, targetFOV, delta * 8.0)

func calcHeadbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func performRaycast():
	if lastCollided:
		var lastLabel = lastCollided.get_node("Label")
		lastLabel.visible = false
		lastCollided = null
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		if collider is Enemy:
			var enemyLabel = collider.get_node("Label")
			enemyLabel.visible = true
				
			lastCollided = collider

#func handleIput():
	#"""
	#What will happen when we look at the LABEL
	#"""
	#var correctKey = false
	#
	#if lastCollided:
		#var keys = lastCollided.keys.split(", ")
		#
		#for key in keys:
			#if Input.is_action_just_pressed(key): # CHECK FOR SPECIFIC KEY INPUT
				#print("correct key pressed: ", key)
				#lastCollided.queue_free()
				#lastCollided = null
				#correctKey = true
				#break
		#if not correctKey:
			#for key in keys:
				#if Input.is_action_just_pressed(key):
					#print("Wrong key pressed: ", key)
					## add smth later here
					
#func handleInput():
	#"""
	#What will happen when we look at the LABEL (STACK VARIATION)
	#"""
	#if lastCollided && lastCollided.keyStack.size() > 0:
		#print("current key stack: ", lastCollided.keyStack)
		#var expectedKey = lastCollided.keyStack.back()     # GET THE LAST KEY FROM THE STACK
		#
		#if Input.is_action_just_pressed(expectedKey):
			#print("CORRECT KEY PRESSED: ", expectedKey)
			#lastCollided.keyStack.pop_back() # remove last key from stack
			#
			## check if stack is empty`
			#if lastCollided.keyStack.size() == 0:
				#print("All keys pressed! YAHOO!!")
				#lastCollided.queue_free()
				#lastCollided = null
		#else:
			## check wrong keys
			#for key in lastCollided.keys.split(" "):
				#if Input.is_action_just_pressed(key):
					#print("Wrong key pressed: ", key)
					#lastCollided.keyStack.clear() # clear stack if wrong key pressed
					#break
					
func handleInput():
	"""
	What will happen when we look at the LABEL (STACK VARIATION)
	"""
	if lastCollided && lastCollided.keyQueue.size() > 0:
		#print("current key stackqueue: ", lastCollided.keyQueue)
		var expectedKey = lastCollided.keyQueue.front()     # GET THE LAST KEY FROM THE STACK
		
		if Input.is_action_just_pressed(expectedKey):
			print("CORRECT KEY PRESSED: ", expectedKey)
			lastCollided.keyQueue.pop_front() # remove first key from queue
			#lastCollided.updateLabel()
			fixError()
			
			# check if queue is empty`
			if lastCollided.keyQueue.size() == 0:
				print("All keys pressed! YAHOO!!")
				lastCollided.queue_free()
				lastCollided = null
		else:
			# check wrong keys
			for key in lastCollided.keys.split(" "):
				if Input.is_action_just_pressed(key):
					print("Wrong key pressed: ", key)
					#lastCollided.keyQueue.clear() # clear stack if wrong key pressed
					playerHealth -= 10
					print(playerHealth)
					break
					
func fixError():
	lastCollided.label.text = " ".join(lastCollided.keyQueue)
	#label.text = " ".join(keyQueue)
	#var completedKeys = lastCollided.keyQueue.slice(0, currentKeyIdx)
	#var remainingKeys = lastCollided.keyQueue.slice(currentKeyIdx, lastCollided.keyQueue.size())
	
